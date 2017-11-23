# DevOps Assessment

# INFRASTRUCTURE REPORT

Please scroll down for discussion and future improvements

# LOCAL DEV ENVIRONMENT APP DEPLOYMENT

- Install Docker & Docker Compose https://docs.docker.com/docker-for-mac/install/#where-to-go-next

From root of infrastructure directory

Build base image
- docker build -f ./common-utils/Dockerfile -t infrabase ./common-utils

Run Docker Compose file
- docker-compose up --build -d

For clean rebuild once changes have been made to the docker files or docker compose file run
- (NEW) docker-compose stop
- docker-compose rm -f
- docker-compose pull
- docker-compose up --build -d

Navigate to localhost:8085





# LOCAL COMMANDS FOR AWS APP DEPLOYMENT

- Install Homebrew https://brew.sh/

Install terraform and ansible via homebrew or follow links for official installations
- Install terraform https://www.terraform.io/downloads.html
- Install ansible http://docs.ansible.com/ansible/latest/intro_installation.html

Create environment variable for your aws keys (replace the variables with your keys)
- export AWS_ACCESS_KEY_ID={{ key }}
- export AWS_SECRET_ACCESS_KEY={{ secret_key }}

- Update the variable office_cidr_range in ./terraform/vpc/global.tf to your office ip range

- Create a Bucket in the region eu-west-2 named (NEW) something like infra-problem, also change ./ansible/roles/jenkins/files/scripts/key/key.sh and update the bucket name from infra-problem to the one you have selected http://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html (This is required to store the terraform state)

Vpc terraform build
- pushd ./terraform/vpc
- terraform init
- terraform apply
- popd

Key Pair Creation
- Create a key pair in aws http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
- Save the .pem file to a location on your local machine and change user permissions to 400
- Use the command "ssh-keygen -y -f /path/to/.pem/file" to output your public key (path to pem referring to the pem file you just downloaded)
- Using the generated public key to update ./terraform/jenkins/jenkins.tf specifically the resource "aws_key_pair" changing the public key parameter (line 50) to the public key you just generated

Jenkins Terraform build
Note this next step is required as the app requires some data that is output via the jenkins terraform build
- pushd ./terraform/jenkins
- terraform init
- terraform apply
- popd


App Terraform build
- pushd ./terraform/app
- terraform init
- terraform apply
- popd

Update Ansible Hosts
- Next in ./ansible/hosts add/edit

[app]
{{ public ip of app instance spun up by terraform }}

The public ip can be found via aws console in the EC2 section the instance will be named app (A dynamic host file using tags to be implemented in future to remove this step)

Run App Ansible Play
- pushd ./ansible
- ansible-playbook app.yml --key-file /path/to/.pem/file
- popd

Navigate To App
- In aws console navigate to EC2 > Load Balancers > app-elb and copy the DNS name of the elb paste this into your browser







# LOCAL COMMANDS FOR AWS JENKINS DEPLOYMENT

 - Add a folder to the infra-problem s3 bucket called keys
 - Add to this folder a file called key.txt with the contents of the .pem file and apply s3 master key encryption to it

 Ensure you have run the steps in "LOCAL COMMANDS FOR AWS APP DEPLOYMENT" above up to "pushd ./terraform/jenkins" from there

Jenkins Terraform Build
 - pushd ./terraform/jenkins
 - terraform init
 - terraform apply
 - popd

Update Dockerfile
 - Update ./ansible/roles/jenkins/files/Dockerfile (line 62) "RUN printf "[app]\n10.1.5.40" > /etc/ansible/hosts" to "RUN printf "[app]\n{{ PRIVATE ip of app ec2 instance }}" > /etc/ansible/hosts"
 - The private ip can be found via aws console in the EC2 section the instance will be named app (A dynamic host file using tags to be implemented in future to remove this step)

Update Snsible Hosts
 - Next in ./ansible/hosts add/edit

 [jenkins]
 {{ public ip of jenkins instance spun up by terraform }}


Run Ansible Play
 - pushd ./ansible
 - ansible-playbook jenkins.yml --key-file /path/to/.pem/file
 - popd

Navigate to Jenkins
 - In aws console navigate to EC2 > Load Balancers > jenkins-elb and copy the DNS name of the elb paste this into your browser or public_ip_of_jenkins_instance:8080

 - Log into jenkins User: admin Password: admin

 3 jobs available

 - deploy_app = destroys old container running app and spins up new one
 - terraform_build = builds aws infrastructure for app
 - terraform_destroy = destroys aws infrastructure for app once finished




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

# POST SUBMISSION REVIEW

# CHANGES THAT HAVE BEEN MADE
- ansible copy takes too long can speed up considerably by referencing each individual file, also investigate synchronize module, folders needed to be created prior to the individual file copy, even if i didn't do it individually on the original submission i should of at least made a comment in the README highlighting the fact that this step takes a long time
- did not take into consideration unquie bucket names within a region therefore my instructions to create a bucket called infra_problem are not possible in eu-west-2 if a different name is used the key.sh script need to be update with the correct s3 bucket name which i also did not reference
- had 2 references of directory mode in the "copy in common-utils" task
- Download docker-compose task not working in local environment however is working in jenkins environment, investigate, for now changed task from "get url" command to "shell: curl... " command (HTTP ERROR 400 BAD REQUEST)
- changed "change permissions Docker compose" shell: chmod to file mode to remove ansible warning
- removed commented out code
- changed logback.xml to log to logfile aswell as stdout and then mapped the log file back to the host in the docker compose file, alternative options change docker file to > log.txt could have implement a data container or configured a log driver
- test in make files wasn't being executed, need to change from %.test to test and implement .PHONY (.PHONY tells Make which targets are not files. This avoids conflict with files of the same name, and improves performance, https://stackoverflow.com/questions/2145590/what-is-the-purpose-of-phony-in-a-makefile) as we had a folder called test in the same directory as the Makefile
- rm target folder in make file not working, since i changed the folder structure the target files were not longer located in their previous positions, change pointers to correct folders
- bootstrap not being picked up by the folder reference, found this via inspecting the page source, changed to CDN bootstrap to resolve. Initially thought this was due to the public folder not being located in the resources folder, changed this and still was unable to get bootstrap working
- no -i host for ansible commands or should have had an ansible.cfg file in the repo to point at the host file in the repo
- set ANSIBLE-HOST-KEY-CHECKING = False through ansible.cfg, not an issue in jenkins
- did not mention in instructions that the user needed to change the repo the jenkins jobs are pointed at to their specific repo by changing the <hudson.plugins.git.UserRemoteConfig> in the job config.xml files
- added to documentation docker-compose stop, containers need to be stopped before they can be removed

# IDEAS FROM POST SUBMISSION REVIEW

- use of terrform workspace for multiple environments
- using terraform module to enable multi environment and multi application builds from minimal code.
- use of multi-stage builds rather than the builder method, this was recently introduced to docker to stop people having to maintain 2 Dockerfiles, (large images take longer to download, take up more disk space, unnecessary components more places to fail)
- include --no-cache in docker build instructions
- suggested use of ASG also leads to vendor lock in as does the implementation of ELBs, task stated that the development of this project needed to be such that vendor lock in was avoided, potentially look into haproxy as an alternative, added operational complexity with haproxy keeping config updated as container are created and destroyed, load balancing strategy must support running multiple versions at the same time for rolling deployments.
- missing favicon could generate one and implement into html (found in google inspect)
- tested stop the quotes and newsfeed container to see if we could fail gracefully or continue (bulkhead principal in microservices) resulted in a 500 error and message "An error occurred when processing your request. Please try again later" look into how to enable to app to still run when one service is available, test are in place to test the error response
- add linting stage


# ELABORATION ON IMPROVEMENTS


# Thing to keep in mind for future development

Loose coupling
High Cohension
Single responsiblity
Separation of concerns
smart endpoints dumb pipes
each service should handle its own data (cant talk to another services data store only the exposed api's)
design for failure of each components
keep in mind asynchronous communication and eventual consistency
easier to update libraries for new feature
consider whether you would be better modulising your code base to better understand service boundaries before extracting the service into its own microservice
new concerns - service discovery, distributed logging, distribution (latency a dozen service calls therefore require asynchronous calls to get acceptable level of performance), hard to debug eventual consistency issues since item is normals consistent by the time the investigation starts
independent deployments reduce the risk associated with the deployment, one small microservice rather than the whole monolith
tests should cover all communication paths plus test failure modes such as timeouts circuit breakers and bulkheads.
test pyramid unit, integration, component, e2e, exploratory
monitoring - resource utilisation (cpu, ram), App response time, App should be set up to make it easy to monitor/analyse user demographics, ci dashboard with commit message if build is broken, deployment frequency (if it hurts...), deployment speed/lead time (time from dev to prod), failure rate/% of successful deployments, time to recovery (chaos monkey). In the same way A/B testing can be used to confirm an application change is having a real effect on your target market, devops changes can evidenced via these metrics (note most likely a teething period so must allow time for methodology to embed in the team before referring to the metrics)   


Conways law - what is the business structure

Docker swarm - https://technologyconversations.com/2016/08/01/integrating-proxy-with-docker-swarm-tour-around-docker-1-12-series/


XP practices
TTD
Pair programming







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
