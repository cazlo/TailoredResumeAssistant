from celery import Celery

from tailored_resume_assistant_backend.model import JobView

celery_app = Celery(
    broker='amqp://guest:guest@task-queue:5672//',
    backend=f"db+postgresql://postgres:password@task-db/postgres" # todo dont dupe
)

@celery_app.task
def generate_tailored_resume(job: JobView):
    # todo:
    #  take actionable info from message and format it for injection into LLM
    #  hit up LLM a bunch to get it to generate text tailored to the job description
    #  save metadata about the job like api calls, any errors/warnings, normalized output from LLM, etc.
    #  save PDF version of generated resume somewhere for easy retrieval/review/use later on (alternatively save HTML and piggy back on brower's PDF rendering functionality)
    #  return only the data we are comfortable with serializing with celery's byte serialization. maybe just pointers to ids of other rows it created
    return {"message": "todo"}
