pipeline {
    agent any

    environment {
        DOTNET_PATH       = 'C:\\Program Files\\dotnet'
        DOCKER_PATH       = 'C:\\Program Files\\Docker\\Docker\\resources\\bin'
        TERRAFORM_PATH    = 'C:\\Users\\user\\OneDrive\\Desktop\\terraform_1.11.3_windows_386'
        AZURE_CLI_PATH    = 'C:\\Program Files\\Microsoft SDKs\\Azure\\CLI2\\wbin'
        CMD_PATH          = 'C:\\Windows\\System32'
        PATH              = "${DOTNET_PATH};${DOCKER_PATH};${TERRAFORM_PATH};${AZURE_CLI_PATH};${CMD_PATH};${PATH}"

        ACR_NAME              = 'kubernetesacr291201'
        AZURE_CREDENTIALS_ID  = 'azure-service-principal-dockerkubernetes'
        ACR_LOGIN_SERVER      = "${ACR_NAME}.azurecr.io"
        IMAGE_NAME            = 'kubernetes291201'
        IMAGE_TAG             = 'latest'
        RESOURCE_GROUP        = 'rg-aks-acr2912'
        AKS_CLUSTER           = 'mycluster291201'
        TF_WORKING_DIR        = 'Terraform'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/vaish29github/Dotnet-Terraform-Docker-Kubernetes-Jenkins.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t %ACR_LOGIN_SERVER%/%IMAGE_NAME%:%IMAGE_TAG% -f DotnetWebApp/Dockerfile DotnetWebApp"
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat """
                        echo "Navigating to Terraform Directory: %TF_WORKING_DIR%"
                        cd %TF_WORKING_DIR%
                        echo "Initializing Terraform..."
                        terraform init
                    """
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat """
                        echo "Navigating to Terraform Directory: %TF_WORKING_DIR%"
                        cd %TF_WORKING_DIR%
                        terraform plan -out=tfplan
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat """
                        echo "Navigating to Terraform Directory: %TF_WORKING_DIR%"
                        cd %TF_WORKING_DIR%
                        echo "Applying Terraform Plan..."
                        terraform apply -auto-approve tfplan
                    """
                }
            }
        }

        stage('Login to ACR') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat "az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID"
                    bat "az acr login --name %ACR_NAME%"
                }
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                bat "docker push %ACR_LOGIN_SERVER%/%IMAGE_NAME%:%IMAGE_TAG%"
            }
        }

        stage('Get AKS Credentials') {
            steps {
                bat "az aks get-credentials --resource-group %RESOURCE_GROUP% --name %AKS_CLUSTER% --overwrite-existing"
            }
        }

        stage('Deploy to AKS') {
            steps {
                bat "kubectl apply -f deployment.yml"
                bat "kubectl get service dotnet-api-service"
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
