from sqlalchemy import Column, String, Boolean, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
import uuid

Base = declarative_base()

class User(Base) :

    __tablename__ = "users"

    #id univoco generato automaticamente come uuid, migliore di incrementi numerici

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))

    #ruolo

    role = Column(String, default="user", nullable=False)

    #email utente, indicizzata e unica

    email = Column(String, unique = True, index = True, nullable = False)

    #password hashata con bcrypt

    hashed_password = Column(String, nullable = False)

    #flag per disattivate account (in caso di sospensione)

    is_active = Column(Boolean, default = True)

    #data nella quale e' stato creato il profilo

    created_at = Column(DateTime, default= datetime.utcnow)

    #data ultimo aggiornamento profilo

    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        #toString dell'user
        return f"<User(id={self.id}, email = {self.email})>"