pipeline {
    agent any

    environment {
        DOTNET_PATH = 'C:\\Program Files\\dotnet'
        DOCKER_PATH = 'C:\\Program Files\\Docker\\Docker\\resources\\bin'
        TERRAFORM_PATH = 'C:\\Users\\user\\OneDrive\\Desktop\\terraform_1.11.3_windows_386'
        AZURE_CLI_PATH = 'C:\\Program Files\\Microsoft SDKs\\Azure\\CLI2\\wbin'
        
        PATH = "${DOTNET_PATH};${DOCKER_PATH};${TERRAFORM_PATH};${AZURE_CLI_PATH};${PATH}"
        
        ACR_NAME = 'kubernetesacr291201'
        AZURE_CREDENTIALS_ID = 'azure-service-principal-dockerkubernetes'
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
        IMAGE_NAME = 'kubernetes291201'
        IMAGE_TAG = 'latest'
        RESOURCE_GROUP = 'rg-aks-acr2912'
        AKS_CLUSTER = 'mycluster291201'
        TF_WORKING_DIR = 'Terraform'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/vaish29github/Dotnet-Terraform-Docker-Kubernetes-Jenkins.git'
            }
        }

        stage('Azure Login') {
            steps {
                withCredentials([azureServicePrincipal(
                    credentialsId: "${AZURE_CREDENTIALS_ID}",
                    subscriptionIdVariable: 'AZ_SUBSCRIPTION_ID',
                    clientIdVariable: 'AZ_CLIENT_ID',
                    clientSecretVariable: 'AZ_CLIENT_SECRET',
                    tenantIdVariable: 'AZ_TENANT_ID'
                )]) {
                    bat '''
                        az login --service-principal -u %AZ_CLIENT_ID% -p %AZ_CLIENT_SECRET% --tenant %AZ_TENANT_ID%
                        az account set --subscription %AZ_SUBSCRIPTION_ID%
                        az role assignment create --assignee a28df90f-6520-4088-92e2-284c8f02a995 --role "User Access Administrator" --scope /subscriptions/b691c69b-aff1-4fe4-b0a8-677e09ce0277
                    '''
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('Terraform') {
                    bat 'terraform init'
                    bat 'terraform apply -auto-approve'
                }
            }
        }
        stage('Docker Build & Push') {
            steps {
                bat """
                    az acr login --name %ACR_NAME% --expose-token
                    docker build -t %ACR_LOGIN_SERVER%/%IMAGE_NAME%:%TAG% .
                    docker push %ACR_LOGIN_SERVER%/%IMAGE_NAME%:%TAG% -f DotnetWebApp/Dockerfile DotnetWebApp
                """
            }
        }

        stage('AKS Authentication') {
            steps {
                bat """
                    az aks get-credentials --resource-group %RESOURCE_GROUP% --name %AKS_CLUSTER_NAME% --overwrite-existing
                """
            }
        }

        stage('Deploy to AKS') {
            steps {
                bat 'kubectl apply -f deployment.yaml'
                
            }
        }
    }

    post {
        success {
            echo 'All stages completed successfully!'
        }
        failure {
            echo 'Build failed.'
        }
    }
}
