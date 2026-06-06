# 🚀 Notes Application Infrastructure

This repository contains the complete deployment lifecycle for a 3-tier Notes application (React Frontend, Django API, PostgreSQL Database). It was built specifically for the **Kamka IT DevOps Internship Assessment (Summer 2026)**, focusing on clean container hygiene, CI/CD automation, secure reverse-proxying, observability, and production-grade deployment practices.

---

## 🌐 Live Production Environment

* **Live Application (HTTPS):** `https://kamka-ahmed.duckdns.org`
* **Observability Dashboard (Uptime Kuma):** `http://YOUR_EC2_IP:3001`

> Replace the URLs above with your actual production endpoints before submission.

---

## 🎯 Assessment Objectives Covered

✅ Dockerized React Frontend

✅ Dockerized Django Backend

✅ PostgreSQL Database Container

✅ Multi-Service Docker Compose Stack

✅ Secure Environment Variable Management

✅ Production Reverse Proxy (Caddy)

✅ Automatic HTTPS via Let's Encrypt

✅ GitHub Actions CI/CD Pipeline

✅ GitHub Container Registry (GHCR)

✅ Automated EC2 Deployment

✅ Database Backup Automation Script

✅ Health Checks & Service Dependencies

✅ Uptime Kuma Monitoring

---

## 🛠️ Prerequisites

To run the application locally you need:

* Git
* Docker Engine (v20.10+)
* Docker Compose (v2.0+)

Verify installation:

```bash
git --version
docker --version
docker compose version
```

---

## ⚙️ Local Setup & Run Instructions

### 1. Clone Repository

```bash
git clone https://github.com/Ahmed-Taha-Dahmoul/kamka-devops-assessment.git
cd kamka-devops-assessment
```

---

### 2. Configure Environment Variables

Copy the example files:

```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```

The application includes safe fallback defaults for local testing.

---

### 3. Start the Entire Stack

```bash
docker compose up -d --build
```

---

### 4. Verify Services

Frontend:

```text
http://localhost:5173
```

Backend API:

```text
http://localhost:8000/api/notes/
```

Backend Health Endpoint:

```text
http://localhost:8000/health/
```

---

### 5. Stop Everything

```bash
docker compose down -v
```

---

## 📁 Repository Structure

```text
kamka-devops-assessment/
├── .github/
│   └── workflows/
│       └── ci-cd.yml
│
├── backend/
│   ├── core/
│   ├── notes/
│   ├── .env.example
│   ├── Dockerfile
│   └── requirements.txt
│
├── frontend/
│   ├── src/
│   ├── .env.example
│   ├── Dockerfile
│   └── nginx.conf
│
├── scripts/
│   └── backup_db.sh
│
├── Caddyfile
├── docker-compose.yml
├── docker-compose.prod.yml
└── README.md
```

---

## 🐳 Container Architecture

```text
                Internet
                    │
                    ▼
             ┌────────────┐
             │   Caddy    │
             │ HTTPS/TLS  │
             └─────┬──────┘
                   │
       ┌───────────┴───────────┐
       ▼                       ▼
┌────────────┐         ┌────────────┐
│ Frontend   │         │ Backend    │
│ React/Nginx│◄──────► │ Django API │
└────────────┘         └─────┬──────┘
                             │
                             ▼
                      ┌────────────┐
                      │ PostgreSQL │
                      └────────────┘
```

---

## 🌍 Environment Parity (Development vs Production)

### Development

`docker-compose.yml`

* Builds directly from source code.
* Optimized for local development.
* Ports exposed to localhost.
* Rapid iteration and testing.

### Production

`docker-compose.prod.yml`

* Pulls immutable images from GHCR.
* No builds occur on EC2.
* Application services remain private.
* Traffic routed exclusively through Caddy.
* Automatic HTTPS certificate management.

---

## 🔐 Security Considerations

### Secrets Management

Sensitive values are never committed:

```gitignore
.env
*.env
```

Examples only:

```text
backend/.env.example
frontend/.env.example
```

---

### Non-Root Containers

Application containers run as non-root users whenever possible.

Benefits:

* Reduced attack surface
* Better container isolation
* Follows Docker security best practices

---

### Reverse Proxy Security

Caddy provides:

* Automatic HTTPS
* TLS certificate renewal
* Secure HTTP → HTTPS redirection
* Hidden internal service ports

---

## 🚀 CI/CD Pipeline

GitHub Actions automates the full delivery workflow.

### Pipeline Stages

#### 1. Source Checkout

```yaml
actions/checkout
```

#### 2. Build Images

```bash
docker build
```

#### 3. Run Validation

* Docker build verification
* Container startup verification

#### 4. Push Images

Images are pushed to:

```text
ghcr.io/<github-username>/
```

using commit SHA tags.

Example:

```text
ghcr.io/username/frontend:abc1234
ghcr.io/username/backend:abc1234
```

#### 5. Deploy to EC2

Deployment occurs automatically via SSH:

```bash
docker compose pull
docker compose up -d
```

---

## 📦 Container Registry

Images are stored in GitHub Container Registry (GHCR).

Benefits:

* Immutable artifacts
* Fast deployments
* Rollback capability
* Production reproducibility

---

## 🛡️ Database Backup Automation

A production-friendly backup script is included:

```bash
scripts/backup_db.sh
```

Run manually:

```bash
chmod +x scripts/backup_db.sh
./scripts/backup_db.sh
```

---

### Reliability Features

#### Strict Mode

```bash
set -euo pipefail
```

Prevents silent failures.

#### Container Validation

Verifies PostgreSQL is running before backup begins.

#### Secure Dumps

Uses Docker networking internally without exposing credentials.

#### Retention Policy

Automatically retains only the newest backups.

Example:

```text
backup_2026-06-01.sql
backup_2026-06-02.sql
backup_2026-06-03.sql
backup_2026-06-04.sql
backup_2026-06-05.sql
```

Older backups are removed automatically.

---

## 📊 Monitoring & Health Checks

Every service includes Docker health checks.

Examples:

### PostgreSQL

```bash
pg_isready
```

### Backend API

```bash
curl http://localhost:8000/health/
```

### Frontend

```bash
curl http://localhost
```

---

### Startup Dependency Management

Services wait for dependencies to become healthy:

```yaml
depends_on:
  db:
    condition: service_healthy
```

This prevents race conditions during startup.

---

## 📈 Uptime Kuma Monitoring

Uptime Kuma continuously monitors application availability.

Monitored Targets:

### Frontend

```text
http://frontend:80
```

### Backend

```text
http://backend:8000/health/
```

### PostgreSQL

```text
postgres://postgres:postgres@db:5432/notes_db
```

Query:

```sql
SELECT 1;
```

---

## 🔍 Health Verification Commands

Check running containers:

```bash
docker ps
```

Check container health:

```bash
docker inspect <container-name>
```

View logs:

```bash
docker compose logs -f
```

Specific service logs:

```bash
docker compose logs backend
docker compose logs frontend
docker compose logs db
```

---

## 🧪 Testing Deployment

Verify production services:

### Frontend

```bash
curl https://kamka-ahmed.duckdns.org
```

### Backend Health

```bash
curl https://kamka-ahmed.duckdns.org/health/
```

### Database

```bash
docker exec -it db psql -U postgres
```

---

## 🔄 Rollback Strategy

Because deployments use immutable image tags:

```text
ghcr.io/user/backend:<commit-sha>
ghcr.io/user/frontend:<commit-sha>
```

rolling back simply requires updating the image tag and redeploying.

This provides:

* Fast recovery
* Predictable deployments
* Easy debugging

---

## 📚 Technologies Used

### Frontend

* React
* Vite
* Nginx

### Backend

* Django
* Django REST Framework
* Gunicorn

### Database

* PostgreSQL

### DevOps

* Docker
* Docker Compose
* GitHub Actions
* GitHub Container Registry
* Caddy
* Uptime Kuma
* AWS EC2

---

## 👨‍💻 Author

**Ahmed Taha Dahmoul**

Kamka IT DevOps Internship Assessment — Summer 2026

GitHub:

```text
https://github.com/Ahmed-Taha-Dahmoul
```

Repository:

```text
https://github.com/Ahmed-Taha-Dahmoul/kamka-devops-assessment
```

---

## 📄 License

This project was created solely for the Kamka DevOps Internship Assessment and is provided for evaluation purposes.
