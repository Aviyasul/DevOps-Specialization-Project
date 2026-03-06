cat > app.py << 'EOF'
#!/usr/bin/env python3
"""
Flask AWS Monitor Application
Simple web application for demonstration of Jenkins CI/CD pipeline
"""

from flask import Flask, jsonify
import os

app = Flask(__name__)


@app.route('/')
def home():
    """Home endpoint with welcome message"""
    return jsonify({
        'message': 'Welcome to Flask AWS Monitor!',
        'status': 'running',
        'build': os.getenv('BUILD_NUMBER', 'local')
    })


@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'flask-aws-monitor',
        'version': '1.0.0'
    })


@app.route('/monitor')
def monitor():
    """Monitor endpoint - placeholder for AWS monitoring"""
    return jsonify({
        'status': 'monitoring',
        'services': ['EC2', 'S3', 'RDS'],
        'message': 'AWS services monitoring active'
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF