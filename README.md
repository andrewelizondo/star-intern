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
* Prior to executing 'terraform destroy', you must delete the Bedrock Agent Action group in the console or via AWS CLI command:

```
aws bedrock-agent delete-agent-action-group --action-group-id <action-group-id> --agent-id <agent-id> --agent-version DRAFT --skip-resource-in-use-check
```

### Testing the Vulnerable Bedrock Agent-based Application

#### curl - Send a python file

You can send a python file to the agent-based application using curl. Get the app url/server from the terraform output.

```
curl --location 'http://<server>/api/codeassist/request' \
--form 'instruct="<some instructional text>"' \
--form 'file=@"<code file located in the current directory>"'
```

Example (form with file):
```
curl --location 'http://localhost:8080/api/codeassist/request' \
--form 'instruct="Execute this code"' \
--form 'file=@"test_code.py"'
```

Example (json with instruction only):
```
curl -v -X POST 'http://localhost:8080/api/codeassist/request' \
-H 'Content-Type: application/json' \
-d '{
    "instruct_json": "Execute this code print(\"Hello World\")"
}'
```


## Red Team Attacks

### Prompt Injection Attacks with Promptfoo

1. Install Promptfoo. See [here.](https://www.promptfoo.dev/docs/red-team/quickstart/#initialize-the-project)
2. Change directory to the promptfoo directory.
3. Update the 'url' in promptfooconfig.yaml to use your application endpoint.
4. Run the following command to execute the attack:

npm/brew
```
promptfoo redteam run
```

npx
```
npx promptfoo@latest redteam run
```

5. Run the following command to see the results:

npm/brew
```
promptfoo view
```

npx
```
npx promptfoo@latest view
```