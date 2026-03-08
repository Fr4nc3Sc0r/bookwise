from fastapi import FastAPI
from backend.db.database import engine, Base
from backend.api import books

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Bookwise API", version="1.0.0")

app.include_router(books.router)

@app.get("/")
def root():
    return {"message": "Bookwise API funziona!"}