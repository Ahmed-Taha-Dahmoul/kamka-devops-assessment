# Use a lightweight Python base image
FROM python:3.11-slim

# Set environment variables
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing .pyc files
# PYTHONUNBUFFERED: Ensures console output is not buffered by Docker
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create a non-root user for security
RUN addgroup --system appgroup && adduser --system --group appuser

# Install system dependencies required for psycopg2 and healthchecks
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev curl \
    && rm -rf /var/lib/apt/lists/*

# Copy only the requirements first to leverage Docker layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Change ownership of the app directory to the non-root user
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# Expose the port Gunicorn will run on
EXPOSE 8000

# Run database migrations, then start the Gunicorn server
CMD ["sh", "-c", "python manage.py migrate && gunicorn --bind 0.0.0.0:8000 core.wsgi:application"]