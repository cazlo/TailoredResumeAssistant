from enum import Enum

from sqlmodel import SQLModel, Field


class JobStatus(str, Enum):
    created = 'created'
    queued = 'queued'
    in_progress = 'in_progress'
    success = 'success'
    error = 'error'

class JobView(SQLModel, table=True):
    id: str = Field(default=None, primary_key=True)
    status: JobStatus = JobStatus.created