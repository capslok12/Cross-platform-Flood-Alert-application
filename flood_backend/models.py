# # models.py
# from sqlalchemy import Column, Integer, String, Float, DateTime
# from database import Base
# from datetime import datetime

# class NGO(Base):
#     __tablename__ = "ngos"

#     id = Column(Integer, primary_key=True, index=True)
#     name = Column(String)
#     location = Column(String)
#     contact = Column(String)
#     description = Column(String)

# class HelpRequest(Base):
#     __tablename__ = "help_requests"

#     id = Column(Integer, primary_key=True, index=True)
#     request_type = Column(String)      # "Food", "Water", "Rescue"
#     latitude = Column(Float, nullable=False)
#     longitude = Column(Float, nullable=False)
#     phone = Column(String, nullable=True)
#     details = Column(String, nullable=True)
#     created_at = Column(DateTime, default=datetime.utcnow)



from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from database import Base
from datetime import datetime

class NGO(Base):
    __tablename__ = "ngos"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    location = Column(String)
    contact = Column(String)
    description = Column(String)

class HelpRequest(Base):
    __tablename__ = "help_requests"

    id = Column(Integer, primary_key=True, index=True)
    request_type = Column(String)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    phone = Column(String, nullable=True)
    details = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

# -------------------------
# VOLUNTEER FEATURES
# -------------------------

class Volunteer(Base):
    __tablename__ = "volunteers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    verified_hours = Column(Integer, default=0)

    tasks = relationship("VolunteerTask", back_populates="volunteer")
    badges = relationship("VolunteerBadge", back_populates="volunteer")

class VolunteerTask(Base):
    __tablename__ = "volunteer_tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    completed_at = Column(DateTime, default=datetime.utcnow)
    volunteer_id = Column(Integer, ForeignKey("volunteers.id"))

    volunteer = relationship("Volunteer", back_populates="tasks")

class VolunteerBadge(Base):
    __tablename__ = "volunteer_badges"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    awarded_at = Column(DateTime, default=datetime.utcnow)
    volunteer_id = Column(Integer, ForeignKey("volunteers.id"))

    volunteer = relationship("Volunteer", back_populates="badges")
