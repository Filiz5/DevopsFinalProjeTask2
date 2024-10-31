pipeline {
    agent any
    environment {
        PIPELINE_NAME = "${env.JOB_NAME}"
    }
    parameters {
        choice(name: 'WORKSPACE', choices: ['dev', 'staging', 'prod', 'test'], description: 'Terraform workspace seçiniz')
        booleanParam(name: 'DESTROY', defaultValue: false, description: 'Kaynakları silmek istiyor musunuz?')
    }
    stages {

        stage('Print Pipeline Name') {
            steps {
                script {
                    echo "Pipeline Name: ${PIPELINE_NAME}"
                }
            }
        }

        stage('Set Workspace') {
            steps {
                script {
                    sh "terraform workspace select ${params.WORKSPACE} || terraform workspace new ${params.WORKSPACE}"
                }
            }
        }

        stage('Create Directory for Key Pair') {
            steps {
                script {
                    sh "mkdir -p ${WORKSPACE}"
                }
            }
        }

        stage('Generate AWS Key Pair') {
            when {
                expression { return !params.DESTROY }
            }
            steps {
                script {
                    sh """
                    aws ec2 create-key-pair --key-name ${params.WORKSPACE}-key --query 'KeyMaterial' --output text --region us-east-1 > ${WORKSPACE}/${params.WORKSPACE}-key.pem
                    chmod 400 ${WORKSPACE}/${params.WORKSPACE}-key.pem
                    """
                }
            }
        }

        stage('Terraform Init & Apply') {
            when {
                expression { return !params.DESTROY }
            }
            steps {
                script {
                    sh 'terraform init'
                    sh "terraform apply --auto-approve"
                }
            }
        }

        stage('Retrieve Instance ID') {
            when {
                expression { return !params.DESTROY }
            }
            steps {
                script {
                    def instanceId
                    try {
                        instanceId = sh(script: "terraform output -raw instance_id", returnStdout: true).trim()
                    } catch (Exception e) {
                        error("Instance ID not found. Make sure the output variable 'instance_id' is defined in the Terraform configuration and that 'terraform apply' has been run successfully.")
                    }
                    if (!instanceId) {
                        error("Instance ID is empty. Please check the Terraform configuration for output variable 'instance_id'.")
                    }
                    echo "Instance ID: ${instanceId}"
                }
            }
        }

        stage('Wait for Instance Status Check') {
            when {
                expression { return !params.DESTROY }
            }
            steps {
                script {
                    def instanceId = sh(script: "terraform output -raw instance_id", returnStdout: true).trim()
                    echo "Waiting for instance ${instanceId} to pass status checks..."
                    sh """
                    aws ec2 wait instance-status-ok --instance-ids ${instanceId} --region us-east-1
                    """
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { return params.DESTROY }
            }
            steps {
                script {
                    sh 'terraform init'
                    sh "terraform destroy --auto-approve"
                }
            }
        }

        stage('Delete AWS Key Pair') {
            when {
                expression { return params.DESTROY }
            }
            steps {
                script {
                    sh """
                    aws ec2 delete-key-pair --key-name ${params.WORKSPACE}-key --region us-east-1
                    rm -f ${WORKSPACE}/${params.WORKSPACE}-key.pem
                    """
                }
            }
        }

        stage('Deploy the App') {
            when {
                expression { return !params.DESTROY }
            }
            steps {
                echo 'Deploy the App'
                sh 'ls -l'
                sh 'ansible --version'
                sh 'ansible-inventory -i inventory_aws_ec2.yml --graph'
                sh """
                    export ANSIBLE_HOST_KEY_CHECKING=False
                    export ANSIBLE_PRIVATE_KEY_FILE="${WORKSPACE}/${params.WORKSPACE}-key.pem"
                    ansible-playbook -i inventory_aws_ec2.yml ${params.WORKSPACE}-playbook.yml -vv
                """
            }
        }
    }
}
