from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from sqlalchemy import or_
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
import os

from database import Base, engine, SessionLocal
from models import (
    NGO, HelpRequest,
    Volunteer, VolunteerTask, VolunteerBadge
)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def home():
    return {"message": "Backend is running!"}

# ---------------- NGO ROUTES ----------------

@app.get("/ngos")
def get_ngos(db: Session = Depends(get_db)):
    return db.query(NGO).all()

@app.get("/ngos/{ngo_id}")
def get_ngo(ngo_id: int, db: Session = Depends(get_db)):
    ngo = db.query(NGO).filter(NGO.id == ngo_id).first()
    if not ngo:
        raise HTTPException(status_code=404, detail="NGO not found")
    return ngo

@app.post("/ngos")
def create_ngo(ngo: dict, db: Session = Depends(get_db)):
    new_ngo = NGO(**ngo)
    db.add(new_ngo)
    db.commit()
    db.refresh(new_ngo)
    return new_ngo

# ---------------- NGO PDF EXPORT ----------------

@app.get("/ngos/{ngo_id}/export-report")
def export_ngo_report(ngo_id: int, db: Session = Depends(get_db)):
    ngo = db.query(NGO).filter(NGO.id == ngo_id).first()
    if not ngo:
        raise HTTPException(status_code=404, detail="NGO not found")

    file_path = f"ngo_{ngo_id}_report.pdf"
    c = canvas.Canvas(file_path, pagesize=A4)

    c.setFont("Helvetica-Bold", 16)
    c.drawString(50, 800, f"NGO Activity Report")

    c.setFont("Helvetica", 12)
    c.drawString(50, 770, f"Name: {ngo.name}")
    c.drawString(50, 750, f"Location: {ngo.location}")
    c.drawString(50, 730, f"Contact: {ngo.contact}")

    c.drawString(50, 690, "Activities Summary:")
    c.drawString(70, 660, "- Tasks Completed")
    c.drawString(70, 640, "- Aid Delivered")

    c.showPage()
    c.save()

    return FileResponse(file_path, media_type="application/pdf", filename=file_path)

# ---------------- VOLUNTEER PROFILE ----------------

@app.get("/volunteers/{volunteer_id}/profile")
def volunteer_profile(volunteer_id: int, db: Session = Depends(get_db)):
    volunteer = db.query(Volunteer).filter(Volunteer.id == volunteer_id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Volunteer not found")

    return {
        "name": volunteer.name,
        "verified_hours": volunteer.verified_hours,
        "completed_tasks": [
            {"title": t.title, "completed_at": t.completed_at}
            for t in volunteer.tasks
        ],
        "badges": [
            {"name": b.name, "awarded_at": b.awarded_at}
            for b in volunteer.badges
        ],
    }


#uvicorn main:app --host 127.0.0.1 --port 1898 --reload
