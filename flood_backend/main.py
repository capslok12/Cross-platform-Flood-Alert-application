# from fastapi import FastAPI, Depends, HTTPException
# from fastapi.middleware.cors import CORSMiddleware
# from sqlalchemy.orm import Session
# from sqlalchemy import or_

# from database import Base, engine, SessionLocal
# from models import NGO, HelpRequest

# app = FastAPI()

# # ----------------------------------------------------
# # CORS for Flutter
# # ----------------------------------------------------
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # Create DB tables
# Base.metadata.create_all(bind=engine)


# # DB Session Dependency
# def get_db():
#     db = SessionLocal()
#     try:
#         yield db
#     finally:
#         db.close()


# @app.get("/")
# def home():
#     return {"message": "Backend is running!"}


# # ----------------------------------------------------
# # NGO ROUTES
# # ----------------------------------------------------
# @app.get("/ngos")
# def get_ngos(db: Session = Depends(get_db)):
#     return db.query(NGO).all()


# @app.get("/ngos/search")
# def search_ngos(keyword: str, db: Session = Depends(get_db)):
#     return db.query(NGO).filter(
#         or_(
#             NGO.name.ilike(f"%{keyword}%"),
#             NGO.description.ilike(f"%{keyword}%"),
#             NGO.location.ilike(f"%{keyword}%"),
#         )
#     ).all()


# @app.get("/ngos/{ngo_id}")
# def get_ngo(ngo_id: int, db: Session = Depends(get_db)):
#     ngo = db.query(NGO).filter(NGO.id == ngo_id).first()
#     if not ngo:
#         raise HTTPException(status_code=404, detail="NGO not found")
#     return ngo


# @app.post("/ngos")
# def create_ngo(ngo: dict, db: Session = Depends(get_db)):
#     new_ngo = NGO(
#         name=ngo.get("name"),
#         location=ngo.get("location"),
#         description=ngo.get("description"),
#         contact=ngo.get("contact"),
#     )
#     db.add(new_ngo)
#     db.commit()
#     db.refresh(new_ngo)
#     return new_ngo


# @app.put("/ngos/{ngo_id}")
# def update_ngo(ngo_id: int, ngo_data: dict, db: Session = Depends(get_db)):
#     ngo = db.query(NGO).filter(NGO.id == ngo_id).first()
#     if not ngo:
#         raise HTTPException(status_code=404, detail="NGO not found")

#     ngo.name = ngo_data.get("name", ngo.name)
#     ngo.location = ngo_data.get("location", ngo.location)
#     ngo.description = ngo_data.get("description", ngo.description)
#     ngo.contact = ngo_data.get("contact", ngo.contact)

#     db.commit()
#     db.refresh(ngo)
#     return ngo


# @app.delete("/ngos/{ngo_id}")
# def delete_ngo(ngo_id: int, db: Session = Depends(get_db)):
#     ngo = db.query(NGO).filter(NGO.id == ngo_id).first()
#     if not ngo:
#         raise HTTPException(status_code=404, detail="NGO not found")
#     db.delete(ngo)
#     db.commit()
#     return {"message": "NGO deleted successfully"}


# # ----------------------------------------------------
# # HELP REQUESTS FEATURE (NEW)
# # ----------------------------------------------------
# @app.post("/help-requests")
# def create_help_request(payload: dict, db: Session = Depends(get_db)):

#     req_type = payload.get("request_type") or payload.get("type")
#     lat = payload.get("latitude")
#     lon = payload.get("longitude")

#     if req_type not in ["food", "water", "rescue"]:
#         raise HTTPException(status_code=400, detail="request_type must be 'food', 'water', or 'rescue'")

#     if lat is None or lon is None:
#         raise HTTPException(status_code=400, detail="latitude and longitude required")

#     new_req = HelpRequest(
#         request_type=req_type,      # FIXED
#         latitude=float(lat),
#         longitude=float(lon),
#         phone=payload.get("phone"),
#         details=payload.get("note") or payload.get("details")
#     )

#     db.add(new_req)
#     db.commit()
#     db.refresh(new_req)

#     return new_req



# @app.get("/help-requests")
# def list_help_requests(db: Session = Depends(get_db)):
#     return db.query(HelpRequest).order_by(HelpRequest.created_at.desc()).all()


# # ----------------------------------------------------
# # SEED SAMPLE NGO DATA
# # ----------------------------------------------------
# @app.on_event("startup")
# def seed_data():
#     db = SessionLocal()
#     if db.query(NGO).count() == 0:
#         sample_ngos = [
#             NGO(
#                 name="Helping Hands Foundation",
#                 location="Dhaka, Bangladesh",
#                 contact="01711111111",
#                 description="Provides food, shelter, and education support.",
#             ),
#             NGO(
#                 name="Green Earth Society",
#                 location="Chittagong, Bangladesh",
#                 contact="01722222222",
#                 description="Environment protection and tree plantation activities.",
#             ),
#             NGO(
#                 name="Hope for Children",
#                 location="Sylhet, Bangladesh",
#                 contact="01733333333",
#                 description="Supports orphan children with medical care and education.",
#             ),
#         ]
#         db.add_all(sample_ngos)
#         db.commit()
#     db.close()




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