from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from backend.db.database import get_db
from backend.models.book import Book
from pydantic import BaseModel, validator
from typing import Optional, List
from backend.api.security import verify_api_key
from fastapi import APIRouter, Depends, HTTPException

router = APIRouter(prefix="/books", tags=["books"], Dependencies=[Depends(verify_api_key)])

# impostazione per ricevere/ritornare un libro
class BookSchema(BaseModel):
    title: str
    author: str
    summary: Optional[str] = None
    audio_path: Optional[str] = None
    cover_path: Optional[str] = None
    duration: Optional[int] = None
    category: Optional[str] = None

    
    class Config:
        orm_mode = True

#GET /books -- lista tutti i libri
@router.get("/", response_model=List[BookSchema])
def get_books(db: Session = Depends(get_db)):
    return db.query(Book).all()

@router.get("/{book_id}", response_model=BookSchema)
def get_book(book_id: int, db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Libro non trovato, cerca bene")
    return book

@router.post("/")
def create_book(book: BookSchema, db : Session = Depends(get_db)):
    new_book = Book(**book.dict())
    db.add(new_book)
    db.commit()
    db.refresh(new_book)
    return new_book


@router.delete("/{book_id}")
def delete_book(book_id: int, db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Libro non trovato")

    db.delete(book)
    db.commit()

    return {"detail": "Libro eliminato"}


#GET libro BY query (nomeLibro)
@router.get("/search")
def search_books(q: str, db : Session = Depends(get_db)):
    results = db.query(Book).filter(
        Book.title.ilike(f"%{q}%") |
        Book.author.ilike(f"%{q}%") |
        Book.category.ilike(f"%{q}%")
    ).all()
    return results
