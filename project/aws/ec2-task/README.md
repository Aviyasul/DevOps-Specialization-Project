# AWS EC2 Resource Viewer

This project provides a Flask web application that displays your AWS EC2 resources, VPCs, Load Balancers, and AMIs in a simple dashboard. It uses Boto3 to interact with AWS and renders the results in an HTML table.

## Features
- Lists EC2 instances (ID, state, type, public IP)
- Shows VPCs and their CIDR blocks
- Displays Load Balancers and DNS names
- Lists AMIs owned by your account

## Requirements
- Python 3.13 or higher
- Flask
- boto3

## Installation
1. Clone or download this repository.
2. Install dependencies:
   ```bash
   pip install flask boto3
   ```
3. Set your AWS credentials as environment variables:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION` (optional, defaults to `us-east-2`)

## Usage
1. Run the application:
   ```bash
   python ec2code.py
   ```
2. Open your browser and go to `http://localhost:5001` to view the dashboard.

## How It Works
- The app fetches AWS credentials from environment variables.
- It initializes Boto3 clients for EC2 and ELB.
- When you visit the home page, it queries AWS for EC2 instances, VPCs, Load Balancers, and AMIs.
- Results are displayed in tables on a single web page.

## Security Notes
- Do not hardcode AWS credentials in the source code. Use environment variables or AWS IAM roles.
- Make sure your credentials have appropriate permissions for EC2, ELB, and AMI operations.

## License
This project is provided as-is for educational and automation purposes.
