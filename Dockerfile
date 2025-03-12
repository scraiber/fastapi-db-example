# Stage 1: Build stage
FROM python:3.13-alpine as builder

# set working directory
WORKDIR /usr/src

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install python dependencies
RUN pip install --upgrade pip && pip install poetry

# Copy pyproject.toml and poetry.lock (if exists)
COPY pyproject.toml ./
COPY poetry.lock* ./

RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi


# Stage 2: Final stage
FROM python:3.13-alpine

# set working directory
# WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Copy the installed dependencies from the previous stage
COPY --from=builder /usr/local /usr/local
ENV PATH=/usr/local/bin:$PATH

WORKDIR /usr/src

# Copy your app code
COPY src/app ./app/

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
