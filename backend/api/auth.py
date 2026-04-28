from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import BaseModel, EmailStr
from passlib.context import CryptContext
from datetime import datetime, timedelta
from jose import JWTError, jwt
from dotenv import load_dotenv
import os

from backend.db.database import get_db
from backend.models.user import User

#carica le variabili d'ambiente dal file env


load_dotenv("backend/.env")

SECRET_KEY = os.getenv("SECRET_KEY")

#algoritmo usato per firmare i token jwt

ALGORITHM = "HS256"

#tempo scadenza token in min

ACCESS_TOKEN_EXPIRE_MINUTES = 30 

#hashing password con bcrypt

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

#schema oauth2 che dice a fastapi dove trovare il token, che viene cercato nell'header Authorization

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

#router per raggruppare tutti gli endpoint di destinazione

router = APIRouter(prefix="/auth" , tags=["auth"])

#modelli pydantic per validazione dati

class UserRegister(BaseModel):

    #validazione dei campi con fastapi
    email:EmailStr
    password:str

    class Config:
        example = {
            "email" : "user@example.com",
            "password" : "password123"
        }
        
class UserLogin(BaseModel):
    #modello per il login
    email: EmailStr
    password: str

class Token(BaseModel):
    #modello per la risposta dopo il login, conterrà il token che verrà depoasto dal frontend
    access_token: str #token jwt da usare per richieste autenticate
    token_type: str #sempre bearer per oauth2
    user_id: str

class UserResponse(BaseModel):
    #modello per la risposta dell'utente, ritorna solo dati pubblici e non password
    id: str
    email: str
    is_active : bool
    role: str
    created_at : datetime

    class Config:
        from_attributes = True #permette la conversione da oggetto SQLAlchemy

##funzionalità di utilità

def hash_password(password:str) -> str:
    #funzione per hashare le password
    return pwd_context.hash(password)

def verify_password(plain_password:str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(user_id:str, expires_delta: timedelta = None) -> str:
    """
    Crea un JWT token per l'utente.
    
    JWT (JSON Web Token) è un standard per i token di autenticazione.
    Contiene informazioni firmate che non possono essere modificate.
    
    Struttura JWT:
    1. Header: tipo di token e algoritmo
    2. Payload: i dati (sub = subject = user_id)
    3. Signature: firma per verificare che non sia stato modificato
    
    """
    if expires_delta is None:
        expires_delta = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
     
    #data e ora di scadenza
    expire = datetime.utcnow() + expires_delta

    #dati che vengono aggiunti nel token
    to_encode = {"sub": user_id, "exp":expire}

    #codifica e firma il token con la jwt key
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm = ALGORITHM)

    return encoded_jwt

async def get_current_user(token:str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    """
    Dependency che verifica il token JWT e restituisce l'utente corrente.
    
    Viene usato negli endpoint che richiedono autenticazione.
    Esempio:
        @app.get("/protected")
        async def protected_route(current_user: User = Depends(get_current_user)):
            return {"message": f"Ciao {current_user.email}"}
    
    Args:
        token: Il token JWT estratto dall'header Authorization
        db: Sessione del database
        
    Returns:
        L'oggetto User dal database
        
    Raises:
        HTTPException: Se il token non è valido o l'utente non esiste
    """
    #eccezione in caso di errore
    credential_exception= HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail = "Credenziali non valide",
        headers = {"WWW-Authenticate" : "Bearer"} #header standard oauth2
    )

    try:
        #decodifica e verifica il token, in caso di manomissione genera eccezioni
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])

        #estrae l'user id dal token (il sub)
        user_id : str = payload.get("sub")

        if user_id is None:
            raise credential_exception
    except JWTError:
        #token non valido, scaduto, modificato
        raise credential_exception
    
    #cerca l'utente nel database a partire dal token
    user = db.query(User).filter(User.id == user_id).first()

    if user is None:
        raise credential_exception
    
    return user


#funzione che verifica il ruolo
async def require_admin(current_user: User = Depends(get_current_user)) -> User:
    if(current_user.role != "admin"):
        raise HTTPException(
            status_code = status.HTTP_403_FORBIDDEN,
            detail = {"Accesso negato, riservato agli admin"},
        )
    return current_user


async def get_admin_user(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role != "admin":
        raise HTTPException(
            status_code = status.HTTP_403_FORBIDDEN,
            detail = "Accesso riservato ai soli amministratori"
        )
    return current_user

#endpoint api routers

@router.post("/register", response_model=UserResponse)
async def register(user_data: UserRegister, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(
            status_code = status.HTTP_400_BAD_REQUEST,
            detail = "email già registrata"
        )
    
    #crea nuovo oggetto user hashando la passwd prima di salvarla
    new_user= User(
        email=user_data.email,
        hashed_password= hash_password(user_data.password),
    )


    #salvataggio dell'utente nel database
    db.add(new_user)

    db.commit()

    db.refresh(new_user)

    return new_user

@router.post("/login", response_model=Token)
async def login(user_data:UserLogin, db: Session = Depends(get_db)):

    user = db.query(User).filter(User.email == user_data.email).first()

    if not user or not verify_password(user_data.password, user.hashed_password):
        raise HTTPException(
            status_code = status.HTTP_401_UNAUTHORIZED,
            detail = "Email o password non corretti",
            headers={"WWW-Authenticate" : "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code = status.HTTP_403_FORBIDDEN,
            detail = "Utente disattivato",
        )
    
    #crea il jwt token per l'utente
    access_token = create_access_token(user.id)

    return {
        "access_token" : access_token,
        "token_type" : "bearer",
        "user_id" : user.id
    }

@router.get("/me", response_model=UserResponse)
async def get_me(current_user : User = Depends(get_current_user)):
    return current_user