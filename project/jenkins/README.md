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
└── README.md          # This file
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

1. **Clone Repository**
   - Checks out the source code

2. **Static Analysis (Parallel)**
   - Linting: Flake8, ShellCheck, Hadolint
   - Security Scanning: Trivy, Bandit

3. **Build Docker Image**
   - Builds Docker image with Jenkins build number
   - Image naming: `aviasul/aviya-jenkins-app:${BUILD_NUMBER}`

4. **Push to Docker Hub**
   - Authenticates with Docker Hub credentials
   - Pushes image to registry: `aviasul/aviya-jenkins-app:${BUILD_NUMBER}`

**Jenkins Configuration:**
- Agent: Any
- Docker Hub User: `aviasul`
- Image Name: `aviya-jenkins-app`
- Credential ID: `aviyajenkins`

**Post Actions:**
- Success: Confirmation message
- Failure: Error notification

### .gitignore
Standard Python project ignore rules.

**Ignored Items:**
- Python cache and compiled files (`__pycache__/`, `*.pyc`)
- Virtual environments (`venv/`, `env/`)
- IDE configurations (`.vscode/`)
- OS files (`.DS_Store`, `Thumbs.db`)
- Build artifacts (`dist/`, `build/`)
- Jenkins cache (`.jenkins/`)
- Log files (`*.log`)

## Prerequisites

### Local Development
- Python 3.9 or higher
- pip package manager
- Flask 2.3.3

### CI/CD Pipeline
- Jenkins server
- Docker and Docker daemon running
- Docker Hub account with credentials configured in Jenkins
- Git repository access

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

## API Endpoints

### GET /
Home endpoint with welcome message
```json
{
  "message": "Welcome to Flask AWS Monitor!",
  "status": "running",
  "build": "123"
}
```

### GET /health
Health check endpoint
```json
{
  "status": "healthy",
  "service": "flask-aws-monitor",
  "version": "1.0.0"
}
```

### GET /monitor
AWS monitoring endpoint
```json
{
  "status": "monitoring",
  "services": ["EC2", "S3", "RDS"],
  "message": "AWS services monitoring active"
}
```

## Docker Usage

### Build Image
```bash
docker build -t aviya-jenkins-app:latest .
```

### Run Container
```bash
docker run -d -p 5000:5000 --name flask-monitor aviya-jenkins-app:latest
```

### Access Container
```bash
curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/monitor
```

### Stop Container
```bash
docker stop flask-monitor
docker rm flask-monitor
```

## Jenkins Pipeline Setup

### Prerequisites
1. Jenkins server running
2. Docker plugin installed
3. Docker Hub credentials configured in Jenkins

### Credentials Setup
In Jenkins UI, add Docker Hub credentials:
- Credential Type: Username with password
- Credential ID: `aviyajenkins`
- Username: Your Docker Hub username
- Password: Your Docker Hub password/token

### Pipeline Execution
The pipeline runs automatically on push events and:
1. Clones the repository
2. Runs static analysis and security checks (parallel)
3. Builds Docker image with unique build number
4. Pushes to Docker Hub registry

### View Pipeline
```bash
# View Jenkins logs
tail -f /var/log/jenkins/jenkins.log

# Access Jenkins UI
http://your-jenkins-server:8080
```

## Docker Hub Repository

Images are published to: [Docker Hub - aviasul/aviya-jenkins-app](https://hub.docker.com/r/aviasul/aviya-jenkins-app)

**Image Naming:** `aviasul/aviya-jenkins-app:<BUILD_NUMBER>`

## Development Workflow

1. **Make Changes**
   ```bash
   git checkout -b feature/your-feature
   # Make code changes
   ```

2. **Test Locally**
   ```bash
   python app.py
   curl http://localhost:5000/health
   ```

3. **Commit & Push**
   ```bash
   git add .
   git commit -m "describe your changes"
   git push origin feature/your-feature
   ```

4. **Jenkins Pipeline**
   - Automatically triggers on push
   - Runs tests and security scans
   - Builds and pushes Docker image

5. **Deploy**
   - Pull image from Docker Hub
   - Deploy to target environment

## Troubleshooting

### Docker Hub Push Fails
- Verify credentials in Jenkins (credential ID: `aviyajenkins`)
- Check Docker Hub token hasn't expired
- Ensure Docker Hub username matches pipeline configuration

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
# Create fresh virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Performance & Scaling

- Flask app runs on port 5000
- Suitable for small-to-medium workloads
- For production, consider using:
  - Gunicorn or uWSGI for WSGI server
  - Kubernetes for orchestration
  - Load balancer for high availability

## Security Notes

- Never commit credentials to repository
- Use Jenkins credential management for secrets
- Use Docker Hub access tokens instead of passwords
- Regular security scans via Trivy and Bandit in pipeline
- Keep dependencies updated regularly

## License

This project is part of the DevOps Challenge portfolio.

## Related Documentation

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Docker Hub Repository](https://hub.docker.com/r/aviasul/aviya-jenkins-app)
