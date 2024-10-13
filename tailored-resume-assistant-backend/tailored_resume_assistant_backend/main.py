from fastapi import FastAPI, Depends

from enum import Enum

# from fastapi_pagination.ext.sqlalchemy import paginate
# from fastapi_pagination import Page, add_pagination, paginate todo
from sqlmodel import SQLModel, create_engine, select, Session, Field

app = FastAPI()
# add_pagination(app)

class JobStatus(str, Enum):
    created = 'created'
    queued = 'queued'
    in_progress = 'in_progress'
    success = 'success'
    error = 'error'

class JobView(SQLModel, table=True):
    id: str = Field(default=None, primary_key=True)
    status: JobStatus = JobStatus.created


db_url = f"postgresql://postgres:password@task-db/postgres"
engine = create_engine(db_url)


def create_db_and_tables():
    # todo really would want to use alembic, but probably for this app this is good enough
    SQLModel.metadata.create_all(engine)


def get_session():
    with Session(engine) as session:
        yield session

@app.on_event("startup")
def on_startup():
    create_db_and_tables()

@app.get("/")
async def root():
    return {"health": "OK"}

@app.get("/jobs")
async def resume_generation_jobs_listing(session: Session = Depends(get_session)) -> list[JobView]:
    # todo real model with pydantic
    jobs = session.exec(select(JobView).offset(0).limit(100)).all()
    return jobs


@app.post("/jobs")
def create_resume_generation_job(job: JobView, session: Session = Depends(get_session)) -> JobView:
    session.add(job)
    session.commit()
    session.refresh(job)
    return job