# Jenkins Agent Deployment using Terraform and gunicorn

October 20th, 2023

By: Khalil Elkharbibi

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Terraform Infrastructure Setup](#terraform-infrastructure-setup)
- [Setting Up a Jenkins Agent](#setting-up-a-jenkins-agent)
- [Instance Software Installation](#instance-software-installation)
- [Deploying the Application](#deploying-the-application)
- [Enhancing Application Availability](#enhancing-application-availability)
- [Understanding Jenkins Agent](#understanding-jenkins-agent)
- [Troubleshooting](#troubleshooting)
- [Conclusion](#conclusion)

---
## Purpose

### **Terraform and AWS Infrastructure**

Terraform is an Infrastructure as Code (IaC) tool that allows developers and operations teams to define, provision, and manage cloud infrastructure using a declarative configuration language. By using Terraform, you can ensure that your infrastructure is consistent, reproducible, and easily versioned.

In this deployment:

- **VPC (Virtual Private Cloud)**: Acts as an isolated virtual network within AWS, providing a controlled environment where resources are launched. It enhances security and allows for network customization.
  
- **Subnets**: These are subdivisions of the VPC's IP address range, allowing you to place resources in distinct network segments, often aligning with design considerations like availability or function separation.
  
- **EC2 Instances**: Virtual servers in Amazon's Elastic Compute Cloud (EC2) where the application and its supporting services run. In this deployment, one instance is dedicated to Jenkins, while the others host the application.
  
- **Security Groups**: Act as virtual firewalls, controlling inbound and outbound traffic to EC2 instances. By specifying allowed ports (e.g., 8080, 8000, 22), we ensure that only legitimate traffic reaches our application and Jenkins server.

### **Jenkins and Continuous Integration/Continuous Deployment (CI/CD)**

Jenkins is an open-source automation server that facilitates CI/CD, a development practice where developers integrate code into a shared repository frequently. This approach allows teams to detect and address issues early, ensuring rapid, reliable, and automated deployments.

- **Jenkins Master and Agent**: The master handles task scheduling, while agents execute these tasks. By setting up a Jenkins agent, you can distribute the build load, run parallel builds, or even run builds in entirely different environments.

- **Multibranch Pipeline**: This Jenkins feature automatically creates a pipeline for each branch in your repository. It's particularly useful for teams that use branch-based development strategies, as it ensures that every branch gets tested.

### **GitHub Repository Management**

GitHub is a platform for version control and collaboration, allowing multiple people to work on projects concurrently. In the context of this deployment:

- The repository acts as the central source of truth, storing the application code, Jenkinsfile, and other essential files.
  
- By integrating Jenkins with GitHub, any change in the repository (like a code push) can trigger a Jenkins build, ensuring that the application is continuously tested and deployed.

### **Why This Deployment Strategy?**

> This deployment strategy ensures that the application is resilient, scalable, and easily maintainable. By automating infrastructure provisioning with Terraform and integrating CI/CD practices with Jenkins, the deployment process becomes more efficient, reducing manual errors and accelerating release cycles. The use of AWS services, like VPC and EC2, ensures that the application is hosted in a secure, scalable, and high-availability environment.
---

## Prerequisites

- **AWS Account**: Required to provision cloud resources.
- **Terraform**: Infrastructure as Code (IaC) tool to automate the provisioning of AWS resources.
- **Jenkins**: An open-source automation server used for continuous integration and continuous delivery (CI/CD).

---

## Terraform Infrastructure Setup

1. **AWS Key Pair**: Before creating new instances, generate a new key pair in AWS. Save the `.pem` file on your computer and attach this private key to all your instances. This ensures secure SSH access to your instances.
   
2. **Terraform Configuration**:
   - Define the AWS provider with the necessary credentials.
   - Create a VPC with the specified CIDR block.
   - Define two public subnets within different availability zones.
   - Set up a security group with ports 8080, 8000, and 22 open.
   - Launch three EC2 instances within the defined subnets. One for Jenkins and two for the application.
   - Create a route table associated with the VPC.

Reason: Terraform provides an Infrastructure as Code (IaC) approach, ensuring that cloud resources are provisioned consistently and reproducibly.

---

## GitHub and Jenkins Integration

### Overview

GitHub acts as the central repository from which Jenkins fetches files to orchestrate the build, test, and deployment processes for the URL Shortener application.

### Modifications in the Repository for Jenkins Build Deployment_5.1

For this deployment, the Jenkinsfile has been pre-configured to terminate the Gunicorn process and deploy the application from the first jenkins agent server during the "Clean" and "Deploy" stages. Our objective is to modify the Jenkinsfile to also include the termination of the Gunicorn process and deployment of the application from the second jenkins agent server.

### Git Commands for Repository Setup and Modification

```bash
# Clone the repository
git clone https://github.com/kura-labs-org/deployment_5.1.git

# Navigate into the repository directory
cd deployment_5.1/

# Initialize a new Git repository
git init

# Set the remote URL to your GitHub repository
git remote set-url origin https://github.com/atlas-lion91/Deployment_5.1.git

# Fetch the latest changes from the remote repository
git fetch

# Push the changes to your repository
git push --mirror

# Create and switch to a new branch named 'second'
git branch second
git switch second

# At this point, make the necessary edits to the Jenkinsfile

# Commit the changes made to the Jenkinsfile
git commit -a

# Push the changes to the 'second' branch on the remote repository
git push --set-upstream origin second

# After verifying the changes, switch back to the 'main' branch
git switch main

# Merge the changes from the 'second' branch into 'main'
git merge second

# Push the merged changes to the 'main' branch on the remote repository
git push
```

By following the above steps, you'll have successfully integrated your GitHub repository with Jenkins, ensuring that any changes made to the application are automatically reflected in the Jenkins build and deployment processes.

## Setting Up a Jenkins Agent

1. **Build Executor Status**: Navigate to the "Build Executor Status" on the Jenkins dashboard.
2. **New Node**: Click on "New Node".
3. **Node Configuration**: Name the node "awsDeploy" and select "Permanent Agent". This designates a dedicated machine for Jenkins to run jobs.
4. **Remote Root Directory**: Set the remote directory to "/home/ubuntu/agent1". This is where Jenkins will store files related to the build.
5. **Labels**: Assign the label "awsDeploy" to the node. Labels help in directing specific jobs to run on this agent.
6. **Launch Method**: Choose "Launch agent via SSH". This allows Jenkins to connect to the agent using SSH.
7. **Host**: Enter the public IP of the EC2 instance designated for the Jenkins agent.
8. **Credentials**: Add the SSH private key that corresponds to the key pair used when launching the EC2 instance.
9. **Verification Strategy**: Select "non-verifying verification strategy" for simplicity, but in a real-world scenario, it's recommended to verify the host key for security reasons.

Reason: A Jenkins agent allows for distributed builds, offloading some of the build and test tasks from the master. This ensures faster build times and can also cater to platform-specific build requirements.

---

## Instance Software Installation

1. **Jenkins Instance**:
   - Install `software-properties-common` to manage software repositories.
   - Add the `deadsnakes` PPA repository to get newer versions of Python.
   - Install `python3.7` and `python3.7-venv` for a specific Python version and virtual environment capabilities.
   - Install the Jenkins plugin “Pipeline Keep Running Step” to enhance pipeline functionalities.

2. **Other Instances**:
   - Install `default-jre` for Java Runtime Environment, necessary for running Java applications.
   - Install `software-properties-common` and add the `deadsnakes` PPA repository.
   - Install `python3.7` and `python3.7-venv`.

Reason: These software installations ensure that the Jenkins instance has the necessary tools for CI/CD processes, while the other instances are equipped to run the application and associated scripts.

---

## Deploying the Application

1. **Jenkins Multibranch Pipeline**:
   - Create a Jenkins multibranch pipeline.
   - Add your repository containing the Jenkinsfile.
   - Jenkins will automatically scan the repository and build branches containing the Jenkinsfile.
   - Reason: Multibranch pipelines allow Jenkins to automatically recognize and execute Jenkinsfiles from different branches, facilitating CI/CD for multiple feature developments or versions.

**Jenkins Build First Instance**

![Screenshot 2023-10-20 223856](https://github.com/atlas-lion91/Deployment_5.1/assets/140761974/5d4bbb13-8f86-4b5a-b296-7815be68ee0b)


![Screenshot 2023-10-20 215555](https://github.com/atlas-lion91/Deployment_5.1/assets/140761974/df7c4129-3597-4ad4-bbc9-30bdb9a21b1b)


**Jenkins Agent Build Second Instance**

![Screenshot 2023-10-20 222250](https://github.com/atlas-lion91/Deployment_5.1/assets/140761974/c397dbd4-ca12-4ba4-9ba6-75b93f20f69a)


**Jenkins Agent Build Third Instance**

![Screenshot 2023-10-20 222325](https://github.com/atlas-lion91/Deployment_5.1/assets/140761974/d57bb89f-3d9e-4a3a-a262-5e26a1ee36f8)

---


**Retail Banking Application Deployed on the Second Instance**

![Screenshot 2023-10-20 222203](https://github.com/atlas-lion91/Deployment_5.1/assets/140761974/c135acde-1c1d-4c38-af96-15bd04ecc54a)

2. **Deploying on the Third Instance**:
   - Use Jenkins to trigger a deployment script or tool that targets the third EC2 instance.
   - Ensure the third instance has the necessary environment and dependencies set up.
   - Reason: The third instance can serve as a staging or production environment, separate from the build and test environments.

**Retail Banking Application Deployed on the Third Instance**
![Screenshot 2023-10-20 222515](https://github.com/atlas-lion91/Deployment_5.1/assets/140761974/f8190dec-3e16-473e-a2e8-1b0dbe810bf5)

---

## Enhancing Application Availability

To make the application more available to users:

1. **Load Balancers**: Implement AWS Elastic Load Balancers (ELB) to distribute incoming application traffic across multiple targets, such as EC2 instances.
2. **Auto Scaling**: Use AWS Auto Scaling to ensure that you have the right number of EC2 instances available to handle the load for your application.
3. **Multi-Region Deployment**: Deploy the application in multiple AWS regions to serve users from the nearest location, reducing latency.
4. **Content Delivery Network (CDN)**: Use AWS CloudFront to cache the application content closer to the end-users.

Reason: These measures ensure high availability, fault tolerance, and reduced latency, providing a seamless experience for users.

---

## Understanding Jenkins Agent

A Jenkins agent is a computational resource with a specific OS that Jenkins uses to execute parts of a job. The main reasons for using Jenkins agents are:

1. **Distributed Builds**: Allows Jenkins to execute builds on different systems, helping in faster build and test processes.
2. **Platform-Specific Builds**: If your application needs to be built or tested on different platforms (e.g., Windows, Linux, macOS), agents facilitate this.
3. **Scale**: As the number of jobs or the size of the builds grows, agents can help distribute the load.
4. **Isolation**: Agents can provide clean, reproducible build environments, ensuring consistency.

---

## Troubleshooting

1. **AWS Credentials**: Ensure that the AWS credentials provided in the Terraform configuration are correct and have the necessary permissions.

  
2. **Terraform State**: If there are discrepancies between the actual AWS resources and what Terraform believes is the state, consider using `terraform refresh` or checking the `terraform.tfstate` file.
3. **Jenkins SSH Authentication**: Ensure that the private key used to authenticate the Jenkins agent matches the public key on the EC2 instance. Also, ensure the username (typically `ubuntu` for Ubuntu instances) is correct.
![image](https://github.com/atlas-lion91/Deployment_5.1/assets/140761974/8a2a87b1-da7e-40d9-be9b-e6617f8eb93a)

---

## Conclusion

Setting up a Jenkins agent on AWS using Terraform automates the deployment process, ensuring consistency and reproducibility. Understanding each step, its purpose, and the underlying concepts ensures a robust and secure CI/CD environment.


