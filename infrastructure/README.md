## Infrastructure

The infrastructure is defined in Terraform and currently deployed to AWS.

# Getting Started
1. Install `terraform` and `aws-cli`
2. Set up your AWS CLI credentials
3. Create a new workspace with the name of your environment: `dev`, `prod`, etc
    - `terraform workspace new dev`
4. Change the following values to unique identifiers:
    - a.  `./main.tf`>`terraform`>`backend "s3"`>`bucket`
      - This is where your terraform state will be held. You need to create this bucket manually, unfortunately.
      - You can use this same bucket for multiple environments and even multiple projects, and it won't be publically visible.
      - All S3 buckets have to be uniquely named (yes, ALL - even ones you didn't create) so putting your name or something is ideal, e.g. `joe-bloggs-terraform-state`.
    - b. `./variables.tf`>`website_bucket_name`>`default`
      - As above, all bucket names must be unique.
      - This bucket is where your FE code will be stored, so call it `joe-bloggs-fun-project-fe-client` or similar.
      - This bucket name won't be publically visible.
      - You won't have to create this manually, it'll be done through Terraform. If you do create it manually and want to then define the same bucket in Terraform you'll need to [import it](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#import)
5. Create your infra for the first time.
    - The command is `terraform apply`
    - It can also be done automatically if using `deploy.yml` in this repo, once you push to `main` branch.
    - Creating the infra can take up to 10 minutes or so for all modules. It'll be faster when just updating.
6. Upload the contents of the frontend `build` folder to the FE client bucket created in step 3a, then invalidate the cache of the created CloudFront distribution. Again, the GitHub Actions `deploy` pipeline can take care of this for you.

# How it works
The frontend code is stored on S3 and hosted via CloudFront to enable HTTPS access.
- We do not use S3 Static Site hosting as this would allow multiple access points to the app, and could confuse users by not allowing them to log in since S3 buckets are HTTP-only while Oauth requires HTTPS - this is why we use CloudFront.
- We use Origin Access Control to prevent access to the S3 bucket except by the authorised CloudFront distribution.
- In order to enable this, the Default Root Object of the CF dist is `/index.html` which provides an entry point to the app. This approach won't work for non-Single Page Applications.
- To prevent browser refreshes from breaking the app, we have a Custom Error Response that redirects 403 errors to `/index.html`, as well as a CloudFront function that appends `index.html` to the forwarded S3 request.
