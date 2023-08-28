# 23-CC-Task1
Have to create/launch Application using Terraform

1. Create the key and security group which allow the port 80.

2. Launch EC2 instance.

3. In this Ec2 instance use the key and security group which we have created in step 1.

4. Launch one Volume (EBS) and mount that volume into /var/www/html

5. Developer have uploded the code into github repo also the repo has some images.

6. Copy the github repo code into /var/www/html

7. Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.

8 Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to update in code in /var/www/html

"About task1.tf"
1.
To go inside directory where " .tf" file is stored.
 {like:- 
  #cd desktop
  #cd hybrid cloud
  #cd tera
  #cd 23_task1 }
2.
 open that .tf file with notepad
  #notepad task1.tf
  (file task1.tf is also attched in the repo)
3.
 Run these commands to initialize plugin as well as to run code
  # terraform init 
  # terraform validate
  #terraform apply -auto-approve

*Output is being attaches after ruuning this file:-"output.png
