# DevOps Assessment

# INFRASTRUCTURE REPORT

Please scroll down for discussion and future improvements

# LOCAL DEV ENVIRONMENT APP DEPLOYMENT

Install Docker & Docker Compose https://docs.docker.com/docker-for-mac/install/#where-to-go-next

From root of infrastructure directory

Build base image
docker build -f ./common-utils/Dockerfile -t infrabase ./common-utils

Run Docker Compose file
docker-compose up --build -d

For clean rebuild once changes have been made to the docker files or docker compose file run
docker-compose rm -f
docker-compose pull
docker-compose up --build -d

Navigate to localhost:8085





# LOCAL COMMANDS FOR AWS APP DEPLOYMENT

Install Homebrew https://brew.sh/

Install terraform and ansible via homebrew or follow links for official installations
Install terraform https://www.terraform.io/downloads.html
Install ansible http://docs.ansible.com/ansible/latest/intro_installation.html

First create environment variable for your aws keys (replace the variables with your keys)
export AWS_ACCESS_KEY_ID={{ key }}
export AWS_SECRET_ACCESS_KEY={{ secret_key }}

First update the variable office_cidr_range in ./terraform/vpc/global.tf to your office ip range

Create a Bucket in the region eu-west-2 named infra-problem http://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html (This is required to store the terraform state)

pushd ./terraform/vpc
terraform init
terraform apply
popd

Create a key pair in aws http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
Save the .pem file to a location on your local machine and change user permissions to 400
Use the command "ssh-keygen -y -f /path/to/.pem/file" to output your public key (path to pem referring to the pem file you just downloaded)
Using the generated public key to update ./terraform/jenkins/jenkins.tf specifically the resource "aws_key_pair" changing the public key parameter (line 50) to the public key you just generated

Note this next step is required as the app requires some data that is output via the jenkins terraform build
pushd ./terraform/jenkins
terraform init
terraform apply
popd

pushd ./terraform/app
terraform init
terraform apply
popd

Next in ./ansible/hosts add/edit

[app]
{{ public ip of app instance spun up by terraform }}

The public ip can be found via aws console in the EC2 section the instance will be named app (A dynamic host file using tags to be implemented in future to remove this step)

pushd ./ansible
ansible-playbook app.yml --key-file /path/to/.pem/file
popd

In aws console navigate to EC2 > Load Balancers > app-elb and copy the DNS name of the elb paste this into your browser







# LOCAL COMMANDS FOR AWS JENKINS DEPLOYMENT

 Add a folder to the infra-problem s3 bucket called keys
 Add to this folder a file called key.txt with the contents of the .pem file and apply s3 master key encryption to it

 Ensure you have run the steps in "LOCAL COMMANDS FOR AWS APP DEPLOYMENT" above up to "pushd ./terraform/jenkins" from there

 pushd ./terraform/jenkins
 terraform init
 terraform apply
 popd

 Update ./ansible/roles/jenkins/files/Dockerfile (line 62) "RUN printf "[app]\n10.1.5.40" > /etc/ansible/hosts" to "RUN printf "[app]\n{{ PRIVATE ip of app ec2 instance }}" > /etc/ansible/hosts"

 The private ip can be found via aws console in the EC2 section the instance will be named app (A dynamic host file using tags to be implemented in future to remove this step)

 Next in ./ansible/hosts add/edit

 [jenkins]
 {{ public ip of jenkins instance spun up by terraform }}

 pushd ./ansible
 ansible-playbook jenkins.yml --key-file /path/to/.pem/file
 popd

 In aws console navigate to EC2 > Load Balancers > jenkins-elb and copy the DNS name of the elb paste this into your browser or public_ip_of_jenkins_instance:8080

 Log into jenkins User: admin Password: admin

 3 jobs available

 deploy_app = destroys old container running app and spins up new one
 terraform_build = builds aws infrastructure for app
 terraform_destroy = destroys aws infrastructure for app once finished




# DISCUSSION

# METHOD

My approach was to use AWS, Terraform, Ansible and Docker to deploy the application. I split the application into 4 containers, firstly a base container which installed the common utilities required between the apps, I then used this base container as the base image for the front-end, newsfeed and quotes containers. Using a base container enables quicker builds for my other containers as the steps in the base container don't need to be rerun additionally after the image had been pulled down to the machine it is cached increasing speed further. I split the application into front-end, newsfeed and quotes as it allows each microservice to scale independently of the other ensuring only parts of the application that require scaling scale rather than the entire application. Docker also provides a consistent build environment reducing the risk associated with the transition from development to production.

I also spent a large portion of my time working on getting a jenkins set up to deploy the application to AWS enabling a click button deployment for the devs, in hindsight I spent far too much time on this and should have instead focused on a local deployment of the application to AWS with a more polished code base, file structure and documentation. Jenkins was also implemented in container with the jobs and plugins implemented through xml files and init groovy scripts.

With regards to AWS i set up a vpc with 2 private and 2 public subnets in 2 separate AZ's, this will enable the application to be multi AZ in the future. My app sat on one ec2 instance and was in the public subnet however in the future the microservices would be split up enabling the the backend services to go to the private subnets. A base security group was set up enabling ports 80 and 22 from the office IP as well as all ports for any other instance in the base SG. I also set up basic route tables using the internet gateway and nat gateway. I also created the relevant key pairs, elbs and aws roles for the app and jenkins instances.

The tooling used terraform for infrastructure management, terraform works well as it is declarative and maintains a state file of the current resources, I used ansible for the execution of the commands on the respective instances. In the future it would be possible to implement pre baked ami's with terraform, ansible and packer to ensure each deployment of a version into different environments is exactly the same.

With regards to jenkins, I would like to implement a pipeline job which will execute tests and the application, the job could have a git hook so that it can run on a dev commit or push getting us closer to continuous integration. For this to be possible we would need more tests including integration tests, acceptance test etc. With regards to multiple environments we would need to implement a naming convention, this naming convention would allow us to target instances in our dynamic ansible host file, additionally each jenkins job would need to be parasitized to enable targeted deployment to each environment. Modules can be implement in terraform to reduce duplication of code with regards to multiple environments.     

Going forward I feel its important to bring Dev and Ops closer together, constant communication is key. I think team rotations ie Ops personnel spends 2 weeks in Dev team and a Dev spends 2 weeks in Ops team are a good way of giving both sides a deeper view of the ways of working. This enables a greater understanding of the problems each team encounter, respective team members can potentially provide constructive input given they are likely coming from a different view point. Currently my team has one hour set aside on Fridays for Ops and Devs to come together and pair program on either personal projects or work. This provides a great opportunity to get to know the people you're working with while learning new skills. Generally the pairs will consist of one Dev and one Ops and the task may be Ops focused or Dev focused, the person with the most knowledge on the subject will lead with an emphasis on teaching your pair the how and why of the implementation rather than completing the task as quickly as possible.

Please see future improvements below.  


# IMPROVEMENTS

AWS
- Deploy app in multiple az's for redundancy
- Utilise AWS ASG for redundancy
- Implement cloud watch alarms for "high cpu/mem" & "low cpu/mem" to provide triggers for the scaling up and down of the ASG to deal with variable loads
- Implement dynamic ansible host based on ec2 instance tags using a set naming convention
- Implement DNS/Route53 this resolves issues around changing IPs
- Create custom AMI rather than using default AWS ECS AMI
- Extract security groups rules from base which are specific to an application into jenkins specific sg / elb specific sg etc.  
- Refine AWS roles and policies currently set to full access to ec2 and s3, find out what the applications actually need access to and lock down everything else

JENKINS
- Jenkins security and users (currently admin:admin with the password in the source code)
- Split deploy app job into deploy jobs for each individual microservice
- Implement pipeline job for tests, deployment etc.
- Implement git hooks for jobs

ANSIBLE
- Implement ansible vault to encrypt passwords and keys which are in the source code

DOCKER
- Implement orchestration tool ie kubernetes
- Implement dynamic port assignment (currently ports will clash if more than port front-end container is spun up on the same ec2 instance)
- Set up nexus/artifactory to push binaries to
- With nexus we can change the Dockerfile to simply pull the binary and run it
- Implement Docker registry for images to be pushed to
- Separate containers into one which builds the binary and pushes to nexus, this ensures an constant build environment, and a container to simply run the application follow the principal of one task to one container
- Set up data volume for the jenkins container

MISC
- Improve file structure
- replace aws links in README.md with awscli commands
- Implement integration tests








# TASK

This project contains three services:

* `quotes` which serves a random quote from `quotes/resources/quotes.json`
* `newsfeed` which aggregates several RSS feeds together
* `front-end` which calls the two previous services and displays the results.

## Prerequisites

* Java
* [Leiningen](http://leiningen.org/) (can be installed using `brew install leiningen`)

## Running tests

You can run the tests of all apps by using `make test`

## Building

First you need to ensure that the common libraries are installed: run `make libs` to install them to your local `~/.m2` repository. This will allow you to build the JARs.

To build all the JARs and generate the static tarball, run the `make clean all` command from this directory. The JARs and tarball will appear in the `build/` directory.

### Static assets

`cd` to `front-end/public` and run `./serve.py` (you need Python3 installed). This will serve the assets on port 8000.

## Running

All the apps take environment variables to configure them and expose the URL `/ping` which will just return a 200 response that you can use with e.g. a load balancer to check if the app is running.

### Front-end app

`java -jar front-end.jar`

*Environment variables*:

* `APP_PORT`: The port on which to run the app
* `STATIC_URL`: The URL on which to find the static assets
* `QUOTE_SERVICE_URL`: The URL on which to find the quote service
* `NEWSFEED_SERVICE_URL`: The URL on which to find the newsfeed service
* `NEWSFEED_SERVICE_TOKEN`: The authentication token that allows the app to talk to the newsfeed service. This should be treated as an application secret. The value should be: `T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX`

### Quote service

`java -jar quotes.jar`

*Environment variables*

* `APP_PORT`: The port on which to run the app

### Newsfeed service

`java -jar newsfeed.jar`

*Environment variables*

* `APP_PORT`: The port on which to run the app
