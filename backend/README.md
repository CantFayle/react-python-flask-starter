## Initial Setup
1. Activate `venv`
    ```
    source venv/bin/activate
    ```

2. Install dependencies
    ```
    pip3 install -r ./requirements-dev.txt --trusted-host files.pythonhosted.org
    ```

3. [Install and run DynamoDB locally](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html)
   The last command will be
   ```
   java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb
   ```
   and you need this running for the app to work.

Then, in a separate terminal window:

4. create local table with composite key, using `user_id` as partition key and `thread_id` as sort key
    ```
    aws dynamodb create-table \
        --table-name and_gpt_message_history \
        --key-schema \
            AttributeName=user_id,KeyType=HASH \
        --attribute-definitions AttributeName=user_id,AttributeType=N \
        --billing-mode PAY_PER_REQUEST \
        --table-class STANDARD \
        --endpoint-url=http://localhost:8000
    ```

5. Run the app:
    ```
    flask --app index
    ```


## Running the app
Once you've finished initial setup, the typical steps to run the app are:

1. Run DynamoDB locally
    ```
    java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb
    ```
Then, in a separate terminal window:

2. Activate venv
    ```
    source venv/bin/activate
    ```

4. Run the app
    ```
    flask --app index
    ```


## Deployment
We deploy the app as a server-less, event-driven application, using [Zappa](https://github.com/zappa/Zappa?tab=readme-ov-file#zappa---serverless-python) to deploy to AWS Lambda and API Gateway

For any of these commands, your `venv` should be activated.

### Setup
1. Install Zappa
    ```
    source /venv/bin/activate
    pip3 install zappa
    ```

2. Install Terraform

   (unnecessary if your terraform --version >=1.7)

    ```
    brew uninstall terraform 
    brew tap hashicorp/tap 
    brew install hashicorp/tap/terraform
    ```

3. Initialise the Terraform `dev` workspace
    ```
    terraform workspace new dev
    ```

4. Initialise Terraform
    ```
    terraform init
    ```

### Deploy an update to an existing environment
Currently, we only have a `dev` environment - to update this you must do as follows:

1. Select the environment you need and deploy the infra (if needed):
    ```
    cd ../infra
    terraform workspace select dev
    terraform init
    terraform plan
    terraform apply
    cd ../backend
    ```
   or
    ```
    terraform -chdir=../infra workspace select dev && terraform -chdir=../infra init && terraform -chdir=../infra plan
    
    terraform -chdir=terraform apply
    ```

4. Activate your `venv` (if needed):
    ```
    source venv/bin/activate
    ```
5. Then simply run this command to update the lambda:
    ```
    zappa update dev
    ```

   This will usually take a couple of minutes.

   As copied from the docs:
   > This creates a new archive,
   uploads it to S3
   and updates the Lambda function to use the new code,
   but doesn't touch the API Gateway routes.

### Get the current API Gateway URL
(e.g. for building the FE app for deployment):

```
zappa status dev | grep "API Gateway URL"  | sed 's/^.* //'
```

This should be run at project root inside your `venv`

### Deploying to a new environment

To deploy to a new environment, we first need to create new infra, then deploy the app to a new environment using Zappa.

In the commands below, replace `<env>` with the appropriate env name

1. Create a new terraform workspace at `/infra`:

    ```
    terraform workspace new <env>
    ```

2. Deploy the new environment infra:

    ```
    terraform init
   
    terraform plan
   
    terraform apply
    ```

3. Deploy the app to Lambda and API Gateway:

    ```
    zappa deploy <env>
    ```
   As copied from the docs:
   > To explain what's going on, when you call deploy, Zappa will
   automatically package up your application and local virtual environment into a Lambda-compatible archive,
   replace any dependencies with versions with wheels compatible with lambda,
   set up the function handler and necessary WSGI Middleware,
   upload the archive to S3,
   create and manage the necessary Amazon IAM policies and roles,
   register it as a new Lambda function,
   create a new API Gateway resource,
   create WSGI-compatible routes for it,
   link it to the new Lambda function,
   and finally delete the archive from your S3 bucket.

4. You may need to update the environment variables for the new env in `zappa_settings.json`

### Troubleshooting
You may need to change the `profile` in `zappa_settings.json` if you don't have an AWS profile called `admin`.