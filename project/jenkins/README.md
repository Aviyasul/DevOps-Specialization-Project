# Jenkins Flask AWS Monitor Application

A Flask-based web application designed to demonstrate a complete Jenkins CI/CD pipeline with Docker containerization and automated deployment to Docker Hub.

## Project Structure

```
jenkins/
├── app.py              # Flask application
├── Dockerfile          # Docker container configuration
├── requirements.txt    # Python dependencies
├── jenkinsfile         # Jenkins pipeline definition
├── .gitignore          # Git ignore rules
└── README.md           # This file
```

## Files Overview

### app.py
Flask application providing a simple REST API for AWS monitoring demonstration.

**Features:**
- **Home Endpoint** (`/`) - Returns welcome message and build number
- **Health Check** (`/health`) - Service health status
- **Monitor Endpoint** (`/monitor`) - AWS services monitoring placeholder

**Environment Variables:**
- `BUILD_NUMBER` - Jenkins build number (optional, defaults to 'local')
- `FLASK_APP` - Set to `app.py`
- `FLASK_ENV` - Set to `production`

### Dockerfile
Containerizes the Flask application for production deployment.

**Specifications:**
- Base Image: `python:3.9-slim`
- Working Directory: `/app`
- Port: 5000
- Dependencies: Installs from `requirements.txt`
- Launch Command: `python app.py`

**Build & Run:**
```bash
docker build -t aviya-jenkins-app:latest .
docker run -p 5000:5000 aviya-jenkins-app:latest
```

### requirements.txt
Python package dependencies.

**Dependencies:**
- Flask 2.3.3

### jenkinsfile
Jenkins declarative pipeline for CI/CD automation.

**Pipeline Stages:**

1. **Clone Repository** - Checks out the source code
2. **Static Analysis (Parallel)**
   - Linting: Flake8, ShellCheck, Hadolint
   - Security Scanning: Trivy, Bandit
3. **Build Docker Image** - Builds Docker image with Jenkins build number (`aviasul/aviya-jenkins-app:${BUILD_NUMBER}`)
4. **Push to Docker Hub** - Authenticates and pushes image to registry

**Jenkins Configuration:**
- Agent: Any
- Docker Hub User: `aviasul`
- Image Name: `aviya-jenkins-app`
- Credential ID: `aviyajenkins`

### .gitignore
Standard Python project ignore rules including `__pycache__/`, `*.pyc`, `venv/`, `.vscode/`, `.DS_Store`, `dist/`, `.jenkins/`, `*.log`

---

## Prerequisites

### Local Development
- Python 3.9 or higher
- pip package manager
- Flask 2.3.3

### CI/CD Pipeline
- Jenkins server running in Docker
- Docker Desktop running
- Docker Hub account with credentials configured in Jenkins
- Git repository access

---

## Installation & Running Locally

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Set Environment Variables
```bash
export FLASK_APP=app.py
export FLASK_ENV=production
```

### 3. Run Application
```bash
python app.py
```

The application will be available at `http://localhost:5000`

---

## API Endpoints

### GET /
```json
{ "message": "Welcome to Flask AWS Monitor!", "status": "running", "build": "123" }
```

### GET /health
```json
{ "status": "healthy", "service": "flask-aws-monitor", "version": "1.0.0" }
```

### GET /monitor
```json
{ "status": "monitoring", "services": ["EC2", "S3", "RDS"], "message": "AWS services monitoring active" }
```

---

## Docker Usage

```bash
# Build
docker build -t aviya-jenkins-app:latest .

# Run
docker run -d -p 5000:5000 --name flask-monitor aviya-jenkins-app:latest

# Test
curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/monitor

# Stop
docker stop flask-monitor && docker rm flask-monitor
```

---

## Jenkins Pipeline Setup

### Step 1 — Start Jenkins Container

Run Jenkins with Docker socket mounted so it can build Docker images:

```bash
docker run -d \
  --name my-jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v //var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

> **Note:** The `-v //var/run/docker.sock:/var/run/docker.sock` flag is required so Jenkins can run `docker build` and `docker push` commands from inside the container.

### Step 2 — Fix Docker Socket Permissions

After the container starts, grant Jenkins permission to use the Docker socket:

```bash
docker exec -u root my-jenkins bash -c "groupadd -f docker && usermod -aG docker jenkins"
docker exec -u root my-jenkins chmod 666 //var/run/docker.sock
docker restart my-jenkins
```

> **Windows users (Git Bash):** Use `//var/run/docker.sock` (double slash) to prevent Git Bash from converting the Unix path to a Windows path.

> **Important:** You must re-run the `chmod` command every time the Jenkins container restarts, as the permission resets:
> ```bash
> docker exec -u root my-jenkins chmod 666 //var/run/docker.sock
> ```

### Step 3 — Get Initial Admin Password

On first login, Jenkins requires an unlock password:

```bash
docker exec my-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Open `http://localhost:8080` and paste the password to unlock Jenkins.

### Step 4 — Configure Docker Hub Credentials

In Jenkins UI:
1. Go to **Manage Jenkins** → **Credentials** → **Global** → **Add Credentials**
2. Fill in:
   - Kind: `Username with password`
   - Username: `aviasul` (your Docker Hub username)
   - Password: your Docker Hub password or access token
   - ID: `aviyajenkins` ← must match exactly

### Step 5 — Create the Pipeline Job

1. Click **New Item** → enter name `aviya-ci-cd-task` → select **Pipeline** → click OK
2. Under **Pipeline** section:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/Aviyasul/DevOps-Specialization-Project.git`
   - Branch: `*/main`
   - Script Path: `project/jenkins/jenkinsfile`
3. Click **Save**

### Step 6 — Run the Pipeline

Click **Build Now** on your pipeline. The pipeline will:
1. Clone the repository
2. Run linting and security scanning in parallel
3. Build the Docker image
4. Push the image to Docker Hub

---

## Troubleshooting

### Docker Permission Denied
```
permission denied while trying to connect to the Docker daemon socket
```
**Fix:**
```bash
docker exec -u root my-jenkins chmod 666 //var/run/docker.sock
```
Then click **Build Now** again. This needs to be re-run after every container restart.

### Docker Hub Push Fails
- Verify credentials in Jenkins (credential ID must be: `aviyajenkins`)
- Check Docker Hub token hasn't expired
- Ensure Docker Hub username matches pipeline configuration (`aviasul`)

### Build Number Not Showing
- Ensure Jenkins is properly setting `BUILD_NUMBER` environment variable
- Check Flask app logs for environment variable access

### Port Already in Use
```bash
# Find process using port 5000
lsof -i :5000
# Kill the process
kill -9 <PID>
```

### Python Dependency Issues
```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

---

## Development Workflow

1. **Make Changes** — work on a feature branch
2. **Test Locally** — `python app.py` then `curl http://localhost:5000/health`
3. **Commit & Push** — `git add . && git commit -m "message" && git push`
4. **Jenkins Pipeline** — triggers automatically on push (or click Build Now)
5. **Deploy** — pull image from Docker Hub and deploy

---

## Docker Hub Repository

Images are published to: [Docker Hub - aviasul/aviya-jenkins-app](https://hub.docker.com/r/aviasul/aviya-jenkins-app)

**Image Naming:** `aviasul/aviya-jenkins-app:<BUILD_NUMBER>`

---

## Performance & Scaling

For production consider: Gunicorn/uWSGI as WSGI server, Kubernetes for orchestration, and a load balancer for high availability.

## Security Notes

- Never commit credentials to the repository
- Use Jenkins credential management for secrets
- Use Docker Hub access tokens instead of passwords
- Regular security scans via Trivy and Bandit are included in the pipeline

## License

This project is part of the DevOps Challenge portfolio.

## Related Documentation

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Docker Hub Repository](https://hub.docker.com/r/aviasul/aviya-jenkins-app)