[![Jenkins](https://img.shields.io/badge/Jenkins-Visit-9B69A0.svg)](https://www.jenkins.io/)
[![HCL](https://img.shields.io/badge/HCL-Hashicorp-3277A0.svg)](https://developer.hashicorp.com/terraform/tutorials)
[![AWS Console](https://img.shields.io/badge/AWS%20Console-Login-orange.svg)](https://aws.amazon.com/console/)
[![Terraform](https://img.shields.io/badge/Terraform-Visit-5C4EE8.svg)](https://learn.hashicorp.com/collections/terraform/getting-started)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Tools-%236c79db)](https://kubernetes.io/docs/tasks/tools/)
[![Docker](https://img.shields.io/badge/Docker-Hub-%232496ED)](https://hub.docker.com/)
[![Snyk](https://img.shields.io/badge/Snyk-Visit-%235C7F31)](https://snyk.io)
[![SonarCloud](https://img.shields.io/badge/SonarCloud-login-%23F37063)](https://sonarcloud.io)
[![OWASP ZAP](https://img.shields.io/badge/OWASP%20ZAP-Visit-%23178B4D)](https://www.zaproxy.org)
[![OWASP](https://img.shields.io/badge/OWASP-Visit-%23F37321)](https://owasp.org)


# MasterJenkins
MasterJenkins is a comprehensive automation pipeline designed for enhancing the security of your applications using Jenkins Continuous Delivery (CD). 
While this configuration employs Maven, it's easily adaptable to other programming languages to suit the needs of your application. 

### Key Features

1. **SAST with SonarCloud:** Comprehensive static code analysis for security and code quality.

2. **SCA with Snyk:** Identify and mitigate project dependency vulnerabilities.

3. **Docker ECR Deployment:** Deploy your app on Docker images within Amazon Elastic Container Registry (ECR).

4. **Kubernetes EKS Deployment:** Easily manage, scale, and run your app within Amazon Elastic Kubernetes Service (EKS).

5. **DAST with ZAP:** Conduct dynamic security testing to identify and address application vulnerabilities, and generate a report.



## Project Overview
This Terraform project is designed to create the necessary infrastructure for running a Jenkins server on Amazon Web Services (AWS). 
It includes the creation of a Virtual Private Cloud (VPC), security groups, an EC2 instance, and other related resources.

## Getting Started
**Before you proceed, make sure you have the following prerequisites in place:**

1. **Terraform installed:**
   
   ```bash
   wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip
   unzip terraform_1.0.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   terraform --version
3. **AWS CLI installed:**
   
   ```bash
   sudo apt-get update   
   sudo apt-get install awscli

## Usage

1. **Clone this repository to your local machine:**
   
   ```bash
   git clone https://github.com/practiccollie/MasterJenkins.git
3. **Open the `main.tf` file and modify the following variables as needed:**
   - `var.region`: The AWS region where you want to create the resources.
   - `var.key_pair_name`: The name of the AWS key pair used to connect to the EC2 instance.
   - `var.vpc_cidr`: The CIDR block for the Virtual Private Cloud (VPC).
   - `var.subnet_cidr`: The CIDR block for the VPC subnet.
   - `var.instance_type`: The EC2 instance type.
   - `var.sg_description`: Description for the security group.
4. **Run the following commands in the`main.tf` file:**
   
   ```bash
   terraform init
   terraform apply --auto-approve
6. **Resources Created:** <br>
   :white_check_mark: AWS Virtual Private Cloud (VPC) <br>
   :white_check_mark: Subnet within the VPC <br>
   :white_check_mark: Internet Gateway for the VPC <br>
   :white_check_mark: Route Table for the VPC <br>
   :white_check_mark: Security Group for the EC2 instance <br>
   :white_check_mark: EC2 instance (Jenkins server) <br>
   :white_check_mark: AWS Key Pair <br>

   
## Jenkins Configuration
After successfully creating the infrastructure, access your Jenkins server by using the public IP or DNS provided.
Follow these steps to quickly set up your Jenkins server for your application:

1. **Start Jenkins:**
   - Access your Jenkins server at the public IP/DNS, e.g., `http://<YOUR IP>.compute-1.amazonaws.com:8081/`.
   - Retrieve the initial Jenkins password from the EC2 instance:
     `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
   - Paste the password into Jenkins to log in.
   - Proceed with "Install suggested plugins."
   - Create your admin username and password, save, and finish.
2. **Configure Maven:**
   - Check your Maven version on the EC2 instance with `mvn -v`.
   - In Jenkins, navigate to **"Manage Jenkins" > "Global Tool Configuration."**
   - Add "Maven 3.5.2" as the name.
   - Uncheck "Install automatically" and set the path to your Maven installation (from the terminal).
   - Click "Apply" and "Save." <br>
   
   **:warning: For applications in different languages: Modify the Jenkinsfile and customize the `setup.sh` file.**
3. **Install Jenkins Plugins:**
   - In Jenkins, go to **"Manage Jenkins" > "Manage Plugins."**
   - Switch to the "Available" tab.
   - Search for and select the following plugins:
     - "Docker Pipeline"
     - "AWS Credentials"
     - "Amazon ECR"
     - "Kubernetes CLI"
   - Click "Install after restart" in the upper right corner.

**Your Jenkins server is now set up and ready to go!**


## Configure SAST With SonarCloud
Once you have successfully configured Jenkins, the next step is to set up Static Application Security Testing (SAST) with SonarCloud.  
Follow the steps below to create and integrate SonarCloud into your Jenkins pipeline:

1. **Create your SonarCloud API Token in your Jenkinsfile as a SAST:**
   - Browse to [sonarcloud.io](http://sonarcloud.io) and sign up with GitHub.
   - Create a new organization in SonarCloud (click the plus icon on the right).
   - Create a name and key name (e.g., practiccollie).
   - Select the free plan → analyze new projects → Next → Previous version → Create Project.
   - Generate a Token in My account → security (located near your account logo).
2. **Add Credentials to Jenkins:**
   - Navigate to **Manage Jenkins > Credentials > System> Global credentials > Add Credentials.**
   - Select "Secret Text" as the "Kind."
   - Enter your Sonar Token as the secret text.
   - Use "SONAR_TOKEN" as the ID, matching the name in the following Jenkinsfile.
   - This is your Jenkinsfile template:
   
     ```
      pipeline {
          agent any
          tools {
              maven 'Maven 3.5.2' 
          }
      
          stages {
              stage('SAST Analysis With SonarCloud') {
                  steps {
                      withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                          sh '''
                              mvn clean verify sonar:sonar
                              -Dsonar.projectKey=<YOUR KEY NAME>
                              -Dsonar.organization=<YOUR ORGANIZATION>
                              -Dsonar.host.url=https://sonarcloud.io
                              -Dsonar.login=${SONAR_TOKEN}
                          '''
                      }
                  }
              }
          }
      }
     ```
  
3. **Create a Pipeline in Jenkins**:
    - Click on "New item" → Enter an item name → Select "Pipeline" → Click "Ok".
    - Scroll down, select a pipeline definition → "pipeline script from SCM" → Under SCM, select "Git".
    - Provide the cloned URL from GitHub (your desired application).
    - Specify the branch (usually **`/main`**) and the Jenkinsfile filename (default is "Jenkinsfile").
    - Apply and save your settings.

4. **Run the Job**: 
    - Click "Build now" on the dashboard to start the **SAST** analysis.
    - After the build is successful, you can browse SonarCloud to analyze the results.


## Configure SCA With Snyk
Now, continue to build your pipeline with Snyk and test all your dependencies for new vulnerabilities by following these steps:

1. **Create a Snyk Account**:
    - Browse to [Snyk](https://app.snyk.io/login) and sign in with GitHub.
    - Generate a Snyk Auth Token from your Snyk account's Account Settings (located at the bottom left).
2. **Adjust Plugin in pom.xml file**:
    - Ensure that your organization is correctly configured in the plugin settings:
      
      ```
      <plugin>
      <groupId>io.snyk</groupId>
      <artifactId>snyk-maven-plugin</artifactId>
      <version>2.0.0</version>
      <inherited>false</inherited>
      <configuration>
        <org><YOUR ORGANIZATION></org>
      </configuration>
    </plugin>
3. **Add Credentials to Jenkins**:
    - Navigate to **Manage Jenkins > Credentials > System > Global credentials > Add Credentials**.
    - Select "Secret Text" as the "Kind."
    - Enter your Snyk Auth Token as the secret text.
    - Use "SNYK_TOKEN" as the ID, matching your Jenkinsfile.
    - This is your Jenkinsfile template:

      ```
      pipeline {
       agent any
   
       tools {
           maven 'Maven 3.5.2'
       }
       
       stages {
           stage('SCA Analysis With Snyk') {
               steps {
                   withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
                       sh 'mvn snyk:test -fn'  // The fn flag forces the build to continue even if Snyk vulnerabilities are found.
                  }
               }
            }
         }
      }
      ```
4. **Run the Job**: 
    - Click "Build now" on the dashboard to start the **SCA** analysis.
    - After the build is successful, you can view the Snyk results in the pipeline.


## Create Docker Image ECR AWS
Before configuring DAST, we need to build and push our application to Amazon **Elastic Container Registry (ECR)**. 
Once the application is hosted in ECR, it can be deployed in Kubernetes (K8S) for further testing. 
Follow the steps below to create a Docker image and store it in ECR:

1. **Create an ECR in AWS console:**
    - Navigate to ECR resouce
    - Create a Repository → Private
    - Name the Repository (e.g., practiccollie) as named in Jenkinsfike → `app = docker.build("practiccollie")`.
    - Create the repository, copy the URI and paste in the Jenkinsfile →  `docker.withRegistry (delete the repo_name)`
2. **Store Docker and AWS secrets in jenkins:**
    - Go to **Manage Jenkins > Credentials > System > Global credentials > Add Credentials**:
        - Select kind "Username with Password".
        - Add your dockerHub login credentials in Username/Password fields.
        - Add **DOCKER_LOGIN** in the ID field (as your variable in Jenkinsfile).
   - Go to **Manage Jenkins > Credentials > System > Global credentials > Add Credentials**:
        -  Select kind "AWS Credentials".
        -  Provide the ID as "AWS_CREDENTIALS".
        -  Grab Your Access and Secret key from AWS file in → `.aws/credentials` and paste them.
   - This is your Jenkinsfile template:

     ```
      pipeline {
          agent any
          tools {
              maven 'Maven 3.5.2'
          }
      
          stage('Build') {
              steps {
                  withDockerRegistry([credentialsId: "DOCKER_LOGIN", url: ""]) {
                      script {
                          app = docker.build("practiccollie")
                      }
                  }
              }
          }
      
          stage('Push') {
              steps {
                  script {
                      docker.withRegistry('https:/<YOUR IMAGE URI>.us-west-2.amazonaws.com', 'ecr:us-west-2:AWS_CREDENTIALS') {
                          app.push("latest")
                      }
                  }
              }
          }
      }
     ```


## Deploy ECR to EKS
In this section, you will create a Kubernetes (K8S) cluster and deploy your application on it, enabling you to run DAST (Dynamic Application Security Testing).
Follow the steps below to create the EKS and deploy the image:

1. **Connect to your EC2 instance via the AWS console or SSH.**
2. **Create an EKS cluster from the CLI. This process may take around 15 minutes.**
    
    ```bash
    eksctl create cluster --name k8s-cluster --version 1.23 --region us-west-2 --nodegroup-name linux-nodes --node-type t2.xlarge --nodes 2
    ```
3. **Check the status of your cluster either in the AWS console (note the zone changes) or from the CLI:**
    
    ```bash
    kubectl get nodes
    ```
4. **Modify your `deploy.yaml` file by replacing `<YOUR URI>` with your image's ECR URI:**
    
    ```yaml
    image: https://<YOUR URI>.dkr.ecr.us-west-2.amazonaws.com/practiccollie
    ```
5. **Create a new namespace in your K8S cluster:**
    
    ```bash
    kubectl create namespace appsec
    ```
6. **Copy the entire content of the file `/home/ec2-user/.kube/config` from your EC2 instance to a local file named `kube_login` (or any name).**
7. **Configure Jenkins Credentials:**
   - In Jenkins, go to **"Manage Jenkins" > "Credentials" > "System" > "Global credentials" > "Add Credentials."**
   - Select the kind as "Secret file" and upload the `kube_login` file from your local machine.
   - Set the ID as "KUBE_LOGIN" (as used in your Jenkinsfile).
   - Use the following Jenkinsfile template:
    
       ```groovy
       pipeline {
           agent any
           tools {
               maven 'Maven 3.5.2'
           }
       
           stages {
               stage('Deploy Your App to EKS') {
                   steps {
                       withKubeConfig([credentialsId: 'KUBE_LOGIN']) {
                           sh('kubectl delete all --all -n appsec')
                           sh('kubectl apply -f deploy.yaml --namespace=appsec')
                       }
                   }
               }
           }
       }
       ```
   **Now you can execute your Jenkins job to deploy your application to K8S, which combines the last three stages.**

8. **Verify the deployment on the Kubernetes cluster:**
    
    ```bash
    kubectl get deployments -n appsec
    ```
9. **Check the services in the specified namespace:**
    
    ```bash
    kubectl get svc -n appsec
    ```
10. **Check the pods and their status within the namespace:**
    
    ```bash
    kubectl get pods -n appsec
    ```
      **Access your deployed application using the CLUSTER-IP or EXTERNAL-IP address in your web browser.**



## Configure DAST With ZAP  

1. **ZAP is pre-configured on the machine.**
2. **You might need to increase your machine's memory for this stage. Here's how to do it:**
     - Stop the EC2 instance.
     - In your EC2 instance settings, go to "Storage," and access the "Volume ID."
     - Click "Modify" in the upper right, and increase your RAM and size.
     - Start your machine again.
     - Use the following Jenkinsfile template:
   
         ```groovy
            pipeline {
                agent any
                tools {
                    maven 'Maven 3.5.2'
                }
            
                stage('DAST With ZAP') {
                    steps {
                        withKubeConfig([credentialsId: 'KUBE_LOGIN']) {
                            sh('zap.sh -cmd -quickurl http://$(kubectl get services/<YOUR APP NAME> --namespace=appsec -o json| jq -r ".status.loadBalancer.ingress[] | .hostname") -quickprogress -quickout ${WORKSPACE}/zap_report.html')
                            archiveArtifacts artifacts: 'zap_report.html'
                        }
                    }
                }
            }
         ```
   
3. **This might take around 20 minutes, depending on your application.**
4. **You can access your ZAP report in the Jenkins Pipeline Artifacts at the top of the page.**
5. **Save the report to your local machine and open it as an HTML file.**

   >💡**The full Jenkinsfile with all stages is provided in this repo**


## Cleanup The Mess From AWS
Before destroying the Terraform infrastructure, make sure to clean up any resources related to the EKS cluster:
1. **Delete the Kubernetes Cluster (do not destroy the Terraform infrastructure before!):**

   ```bash
   eksctl delete cluster --region us-west-2 --name <cluster name>
2. **The deletion process may take approximately 10 minutes, as it erases all resources related to the K8S cluster.**
3. **You'll receive a message confirming that [✔] all cluster resources were deleted.**
4. **Don't forget to delete your Amazon Elastic Container Registry (ECR) repository from the AWS Management Console as well.**
5. **Now delete the entire infrastructure with terraform:**

    ```bash
    terraform destroy --auto-approve
