# note: 3.12 chosen as the "current version -1". alpine chosen for better vuln mgmt compared to debian
FROM python:3.12-alpine

RUN apk update && apk add --no-cache \
    curl \
    build-base \
    libffi-dev \
    openssl-dev

RUN pip install poetry==1.8.3

# Create a non-root user and group
RUN addgroup -S backend && adduser -S backend -G backend

WORKDIR /opt/app

COPY --chown=backend:backend  \
    tailored-resume-assistant-backend/pyproject.toml tailored-resume-assistant-backend/poetry.lock \
    /opt/app/

RUN poetry install --no-root --no-interaction --no-ansi

COPY --chown=backend:backend  tailored-resume-assistant-backend/ /opt/app

RUN poetry install --only-root --no-interaction --no-ansi

EXPOSE 8080

#CMD /bin/sh

CMD ["poetry", "run", "uvicorn", "tailored_resume_assistant_backend.main:app", "--workers", "8"]