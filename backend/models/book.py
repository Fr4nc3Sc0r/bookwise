from sqlalchemy import Column, Integer, String, Text
from backend.db.database import Base

class Book(Base)
    __tablename__ = "books"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    author = Column(String, nullable=False)
    summary=Column(Text, nullable=True)
    audio_path=Column(String, nullable=True)
    cover_path=Column(String,nullable=True)
    duration=Column(String,nullable = True)
    category = Column(String, nullable=True)