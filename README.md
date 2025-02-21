# Star Intern (Vulnerable Bedrock Agent-based Application Scenario)

## Overview
This scenario deploys a vulnerable agent-based application that has the ability to interpret and execute code.
The application is built using golang and utilizes Amazon Bedrock and a code interpreter Bedrock Agent to response to requests.

![Architecture](https://raw.githubusercontent.com/jefferyfry/star-intern/refs/heads/jfry-bedrock-agent-terraform-n-app/images/arch.png)

### Prerequisites

* Terraform installed to execute the terraform scripts for deployment
* Have an AWS Account to deploy the infrastructure
* Docker installed and running
* AWS CLI and Kubectl installed for troubleshooting if necessary

### Deploying the Vulnerable Bedrock Agent-based Application Infrastructure

#### Environment Variables
Ensure the following environment variables are set.

| Environment Variable           | Description                                                                              |
|--------------------------------|------------------------------------------------------------------------------------------|
| AWS_ACCESS_KEY_ID              | Your AWS credentials for terraform deployment only. eg. AKIAQEFWAZ...                    |
| AWS_SECRET_ACCESS_KEY          | Your AWS credentials for terraform deployment only. eg. vjrQ/g/...                       |
| AWS_DEFAULT_REGION             | Your AWS region for terraform deployment only. eg. us-east-2                             |
| TF_VAR_client_id               | The Wiz sensor client ID to be used for sensor install on servers. eg. t3zxg...          |
| TF_VAR_client_secret           | The Wiz sensor client secret to be used for sensor install on servers. eg. Jdy1YH...     |

#### Terraform

1. change directory to the Vulnerable_infra directory
2. execute terraform plan -out tfplan
3. execute terraform apply tfplan

Note: 
* 'terraform apply' will take approximately 15 minutes to deploy the infrastructure
* Prior to executing 'terraform destroy', you must delete the Bedrock Agent Action group in the console.

### Testing the Vulnerable Bedrock Agent-based Application

#### curl - Send a python file

You can send a python file to the agent-based application using curl. Get the app url/server from the terraform output.

```
curl --location 'http://<server>/api/code' \
--form 'instruct="<some instructional text>"' \
--form 'file=@"<code file located in the current directory>"'
```

Example:
```
curl --location 'http://localhost:8080/api/code' \
--form 'instruct="Execute this code"' \
--form 'file=@"test_code.py"'
```

#### Frontend React

Coming soon...

### Deploying the Attack Infrastructure

Coming soon...

#### Environment Variables
Ensure the following environment variables are set.

| Environment Variable           | Description                                                                              |
|--------------------------------|------------------------------------------------------------------------------------------|
| AWS_ACCESS_KEY_ID              | Your AWS credentials for terraform deployment only. eg. AKIAQEFWAZ...                    |
| AWS_SECRET_ACCESS_KEY          | Your AWS credentials for terraform deployment only. eg. vjrQ/g/...                       |
| AWS_DEFAULT_REGION             | Your AWS region for terraform deployment only. eg. us-east-2                             |

#### Terraform

1. change directory to the Vulnerable_infra directory
2. execute terraform plan -out tfplan
3. execute terraform apply tfplan
