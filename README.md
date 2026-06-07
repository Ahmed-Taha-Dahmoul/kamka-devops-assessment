# Kamka IT DevOps Assessment - Notes App Infrastructure

This repository contains a full deployment lifecycle for a 3-tier Notes application (React Frontend, Django API, PostgreSQL Database). It was built specifically for the **Kamka IT Cloud & DevOps Intern** assessment, focusing on reproducibility, clean containerization, and automated CI/CD.

## 🚀 Live Environment (Production)
- **Live Application (HTTPS):** https://kamka-ahmed.duckdns.org
- **Monitoring Dashboard (Uptime Kuma):** http://16.16.61.247:3001

---

## 🛠️ Local Development Setup (Reproducibility)
This project is designed to be **100% reproducible** on any machine. You do not need Node.js or Python installed locally—only Docker and Git.

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- Git

### Step-by-Step Guide
**1. Clone the repository:**
```bash
git clone https://github.com/Ahmed-Taha-Dahmoul/kamka-devops-assessment.git
cd kamka-devops-assessment
```

**2. Supply Secrets / Environment Variables:**
No secrets are committed to this repository. To run the app locally, copy the provided example environment files:
```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```
*Note: The `docker-compose.yml` file uses safe fallback defaults (`${VARIABLE:-default}`). If a reviewer chooses to skip the `.env` step entirely, the application will still build and run perfectly using default local credentials.*

**3. Spin up the stack:**
Run the following command from the root directory:
```bash
docker compose up -d --build
```

**4. Access the Application Locally:**
- **Frontend App:** `http://localhost:5173`
- **Django API Docs/Browser:** `http://localhost:8000/api/notes/`
- **API Healthcheck:** `http://localhost:8000/health/`

To shut down and clean up:
```bash
docker compose down -v
```

---

## 📁 Repository Structure & Highlights

- **`frontend/`**: React/Vite application. Uses a **multi-stage Dockerfile** (Node build -> Nginx Alpine) to keep the final image incredibly small.
- **`backend/`**: Django REST API. Uses a Python Slim image, runs as a **non-root user** (`appuser`), and exposes a `/health/` endpoint.
- **`docker-compose.yml`**: The local Dev environment. Builds code from source and utilizes `depends_on` with `service_healthy` conditions for safe startup ordering.
- **`docker-compose.prod.yml`**: The Production environment. Pulls immutable, pre-built images from GHCR and adds Caddy and Uptime Kuma to the stack.
- **`Caddyfile`**: Reverse proxy configuration that automatically handles routing and provisions HTTPS via Let's Encrypt.
- **`.github/workflows/ci-cd.yml`**: The Trunk-based CI/CD pipeline.
- **`scripts/backup_db.sh`**: A strict, automated Bash script for database backups.

---

## 🔄 CI/CD Pipeline Architecture
The pipeline is powered by **GitHub Actions** and uses **GitHub Container Registry (GHCR)** to store images. It is divided into three distinct stages:

1. **Lint & Test:** Runs automatically on Pull Requests and Pushes. It provides fast feedback by verifying the Django syntax and ensuring the React app successfully compiles before attempting slow Docker builds.
2. **Build & Push:** Runs on pushes to `main`. Builds the multi-stage Docker images and pushes them securely to GHCR, tagged with the Git commit SHA.
3. **Deploy to EC2:** Triggered conditionally (`if: github.ref == 'refs/heads/main'`). Securely copies the production `docker-compose` files to the AWS EC2 instance, pulls the new images, restarts Caddy to apply routing changes, and prunes old dangling images to preserve server disk space.

---

## 🛡️ Bash Automation (Database Backup)
The `scripts/` directory contains a genuine automation script to safely back up the PostgreSQL database without requiring entering the container manually. 

To test it locally while your Docker Compose stack is running:
```bash
chmod +x scripts/backup_db.sh
./scripts/backup_db.sh
```
**Features of this script:**
- Runs in strict mode (`set -euo pipefail`) to fail loudly on any errors.
- Verifies the database container is actually running before attempting a backup.
- Pipes the `pg_dump` output safely to the host machine.
- Automatically cleans up older backups (keeps only the 5 most recent) to prevent disk space exhaustion.

---

## 🌍 Environment Parity (Dev vs. Prod)
A core focus of this infrastructure is maintaining parity between development and production while keeping them secure.
- **Parity:** Both environments run the exact same PostgreSQL version and the exact same application code inside containers.
- **Differences:** Local Development exposes ports directly to `localhost` and builds images from source for rapid iteration. Production pulls immutable artifacts from the registry, hides internal ports, routes all traffic securely through a **Caddy Reverse Proxy**, and actively monitors the stack using **Uptime Kuma**.

---
*Built by Ahmed Taha Dahmoul for the Kamka IT Assessment - Summer 2026*
