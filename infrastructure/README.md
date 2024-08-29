# Infrastructure

The infrastructure is defined in Terraform and currently deployed to AWS.

## Getting Started
### Using the GitHub Actions `deploy.yml` script (recommended):
1. Set up an AWS account and obtain Access Key credentials
2. Set up a Google Oauth Consent screen and Credentials, and obtain the Client ID.
3. Configure your repo's `Settings > Secrets and Variables > Actions` with `GOOGLE_O_AUTH_CLIENT_ID`, `AWS_ACCESS_KEY_ID` and `AWS_SECRET_KEY`
4. In your project, change the following values to unique identifiers:
    <details>
      <summary>a) ./main.tf > terraform > backend "s3" > bucket</summary>
      
      - This is where your terraform state will be held. You need to create this bucket manually, unfortunately.
      - You can use this same bucket for multiple environments and even multiple projects
      - The bucket name won't be publically visible.
      - All S3 buckets have to be uniquely named (yes, ALL - even ones you didn't create) so putting your name or something is ideal, e.g. `joe-bloggs-terraform-state`.
      
    </details>
    <details>
      <summary>b) ./variables.tf > website_bucket_name > default</summary>
      
      - As above, all bucket names must be unique.
      - This bucket is where your FE code will be stored, so call it `joe-bloggs-fun-project-fe-client` or similar.
      - The bucket name won't be publically visible.
      - You won't have to create this manually, it'll be done through Terraform. If you do create it manually and want to then define the same bucket in Terraform you'll need to [import it](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#import)
      
    </details>
      
5. Push your changes to either `main` or `dev` branch - this will kick off the deployment of the infra, backend and frontend to either `prd` or `dev` environment.
    - Creating the infra can take up to 10 minutes or so for all the modules. It'll be faster when just updating.
6. When the frontend job is finished, add the CloudFront Distribution URL (looks like `https://a1b2c3d4e5f6g7.cloudfront.net/`, under the `Print CloudFront URL` step) to your [Google Oauth Credentials](https://console.cloud.google.com/apis/credentials) page, e.g.:
    - Authorized JavaScript origin: `https://a1b2c3d4e5f6g7.cloudfront.net/`
    - Authorized redirect URI: `https://a1b2c3d4e5f6g7.cloudfront.net/api/auth/callback/google`
7. Visit the CloudFront Distribution URL and it should be live for your selected environment!


### Manual:
1. Install `terraform` and `aws-cli` as well as the FE and BE dependencies.
2. Set up your AWS CLI credentials
3. Set up a Google Oauth Consent screen and Credentials, and grab the Client ID.
4. Change the following values to unique identifiers:
    <details>
      <summary>a) ./main.tf > terraform > backend "s3" > bucket</summary>
      
      - This is where your terraform state will be held. You need to create this bucket manually, unfortunately.
      - You can use this same bucket for multiple environments and even multiple projects, and it won't be publically visible.
      - All S3 buckets have to be uniquely named (yes, ALL - even ones you didn't create) so putting your name or something is ideal, e.g. `joe-bloggs-terraform-state`.
      
    </details>
    <details>
      <summary>b) ./variables.tf > website_bucket_name > default</summary>
      
      - As above, all bucket names must be unique.
      - This bucket is where your FE code will be stored, so call it `joe-bloggs-fun-project-fe-client` or similar.
      - This bucket name won't be publically visible.
      - You won't have to create this manually, it'll be done through Terraform. If you do create it manually and want to then define the same bucket in Terraform you'll need to [import it](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#import)
      
    </details>

5. Initialise Terraform:
    - `terraform init`
6. Create a new workspace with the name of your environment: `dev`, `prod`, etc:
    - `terraform workspace new dev`
7. Create your infra for the first time:
    - `terraform apply`
    - Creating the infra can take up to 10 minutes or so for all modules. It'll be faster when just updating.
8. Add the Google Oauth Client ID and your deployed Zappa API Gateway URL to the .env of the frontend, and build the app (`npm run build`)
8. Upload the _contents_ of the frontend `build` folder to the FE client bucket created in step 4b, then invalidate the cache of the created CloudFront distribution.
    - If there's files in there already (e.g. it's not your first deploy) then empty the bucket before uploading the build files.
9. Add the CloudFront Distribution URL (looks like `https://a1b2c3d4e5f6g7.cloudfront.net/`) to your [Google Oauth Credentials](https://console.cloud.google.com/apis/credentials) page

## How it works
The frontend code is stored on S3 and hosted via CloudFront to enable HTTPS access.
- We do not use S3 Static Site hosting as this would allow multiple access points to the app, and could confuse users by not allowing them to log in since S3 buckets are HTTP-only while Oauth requires HTTPS - this is why we use CloudFront.
- We use Origin Access Control to prevent access to the S3 bucket except by the authorised CloudFront distribution, which is why the bucket can safely be "public".
- In order to enable this, the Default Root Object of the CF dist is `/index.html` which provides an entry point to the app. Thus, this approach won't work for non-Single Page Applications.
- To prevent browser refreshes from breaking the app, we have a Custom Error Response that redirects 403 errors to `/index.html`, as well as a CloudFront function that appends `index.html` to the forwarded S3 request.
