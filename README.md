# 🚀 Notes Application Infrastructure

This repository contains the complete deployment lifecycle for a 3-tier Notes application (React Frontend, Django API, PostgreSQL Database). It was built specifically for the **Kamka IT DevOps Internship assessment (Summer 2026)**, focusing on clean container hygiene, CI/CD automation, secure reverse-proxying, and observability.

---

## 🌐 Live Production Environment
- **Live Application (HTTPS):** [https://kamka-ahmed.duckdns.org](https://kamka-ahmed.duckdns.org) *(Replace with your exact DuckDNS domain)*
- **Observability Dashboard (Uptime Kuma):** [http://YOUR_EC2_IP:3001](http://YOUR_EC2_IP:3001) *(Replace with your EC2 IP)*

---

## 🛠️ Prerequisites
To run this application locally, you only need:
- [Git](https://git-scm.com/)
- [Docker Engine](https://docs.docker.com/get-docker/) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+)

---

## ⚙️ Local Setup & Run Instructions (Reproducibility)

Follow these steps to bring up the entire stack locally in less than 2 minutes:

### 1. Clone the repository
```bash
git clone https://github.com/Ahmed-Taha-Dahmoul/kamka-devops-assessment.git
cd kamka-devops-assessment
```

### 2. Supply Your Own Secrets
Security hygiene is maintained by never committing `.env` files. To supply your own environment variables, copy the provided `.example` files:

```bash
# Setup Backend secrets
cp backend/.env.example backend/.env

# Setup Frontend secrets
cp frontend/.env.example frontend/.env
```
*(Note: The `docker-compose.yml` is configured with safe fallback variables. If a reviewer skips this step, the local stack will still build and run with secure defaults).*

### 3. Spin up the Stack
Build and run the Database, Backend API, and Frontend using Docker Compose:
```bash
docker compose up -d --build
```

### 4. Verify the Local Services
Once the containers are running and healthy, you can access:
- **Frontend App:** [http://localhost:5173](http://localhost:5173)
- **Backend API Docs:** [http://localhost:8000/api/notes/](http://localhost:8000/api/notes/)
- **API Healthcheck:** [http://localhost:8000/health/](http://localhost:8000/health/)

To safely stop the local stack:
```bash
docker compose down -v
```

---

## 📁 Repository Structure

```text
kamka-devops-assessment/
├── .github/workflows/
│   └── ci-cd.yml          # GitHub Actions Pipeline (Test, Build, Push, Deploy)
├── backend/
│   ├── core/              # Django settings and URL configurations
│   ├── notes/             # API Models, Views, and Serializers
│   ├── .env.example       # Example environment file
│   ├── Dockerfile         # Python slim production Dockerfile (non-root)
│   └── requirements.txt   # Backend dependencies
├── frontend/
│   ├── src/               # React components and App source code
│   ├── .env.example       # Example frontend env file
│   ├── Dockerfile         # Multi-stage production Dockerfile
│   └── nginx.conf         # Custom Nginx configuration for SPA routing
├── scripts/
│   └── backup_db.sh       # Safe PostgreSQL backup script
├── Caddyfile              # Reverse proxy configuration (Automatic Let's Encrypt HTTPS)
├── docker-compose.yml     # Local Development Configuration
└── docker-compose.prod.yml# Production EC2 Configuration (Pulls from GHCR)
```

---

## 🌍 Environment Parity (Dev vs. Prod)

Great care was taken to ensure development and production environments maintain high parity while serving their distinct purposes:

- **Local Development (`docker-compose.yml`):** Builds images directly from local source code to allow for rapid iteration. Ports are exposed directly to `localhost`.
- **Production (`docker-compose.prod.yml`):** Never builds from source on the target host. It pulls immutable, pre-built Docker artifacts (tagged with the git commit SHA) directly from GitHub Container Registry (GHCR). Application ports are hidden from the public; all traffic is securely routed through a **Caddy Reverse Proxy**, which automatically provisions and manages Let's Encrypt HTTPS certificates.

---

## 🛡️ Bash Automation: Database Backups

A strict, secure bash script is included to automate PostgreSQL database backups. To test it locally while your Docker containers are running:

```bash
chmod +x scripts/backup_db.sh
./scripts/backup_db.sh
```

**Script Design & Reliability Features:**
- Uses **Strict Mode** (`set -euo pipefail`) so it exits immediately if any command, pipeline, or unset variable fails.
- Verifies the database container is active before executing `pg_dump`.
- Executes `pg_dump` securely within the Docker network context without exposing passwords.
- Automatically cleans up old backups (keeping only the 5 most recent) to prevent disk space exhaustion.

---

## 📊 Monitoring & Health Checks

Every service in the `docker-compose` stack utilizes native Docker `healthcheck` instructions (e.g., `pg_isready` for PostgreSQL, `curl` for the Django API). The startup order is strictly controlled using `depends_on: condition: service_healthy` to ensure database readiness before the API initializes.

In the Production environment, **Uptime Kuma** is deployed on port `3001` to continuously monitor the stack:
1. **Frontend App (HTTP):** Monitored internally via `http://frontend:80`.
2. **Backend API Health (HTTP):** Monitored internally via `http://backend:8000/health/`.
3. **Database Health (PostgreSQL):** Monitored directly over port `5432` using the connection string `postgres://postgres:postgres@db:5432/notes_db` and running the query `SELECT 1`.
```