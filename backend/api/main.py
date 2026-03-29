from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from backend.db.database import engine, Base
from backend.api import books

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Bookwise API", version="1.0.0")

# Allow browser-based clients (Flutter Web) to call this API during development.
# Without this, Flutter Web will get "Failed to fetch" due to CORS restrictions.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(books.router)

@app.get("/")
def root():
    return {"message": "Bookwise API funziona!"}