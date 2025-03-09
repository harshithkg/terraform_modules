pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('key')
        AWS_SECRET_ACCESS_KEY = credentials('id')
        AWS_DEFAULT_REGION    = "us-west-1"
    }

    stages {
        
        stage('Terraform Init') {
            steps {
                dir("/mnt/terraform") {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("/mnt/terraform") {
                    sh 'terraform plan -input=false -out=tfplan'
                    sh 'terraform show -no-color tfplan > tfplan.txt'
                }
            }
        }

        stage('Approval Before Apply') {
            steps {
                script {
                    def plan = readFile '/mnt/terraform/tfplan.txt'
                    input message: "Do you want to apply the Terraform plan?",
                          parameters: [text(name: 'Plan', description: 'Review the plan before approval', defaultValue: plan)]
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("/mnt/terraform") {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }

        stage('Get Public IP & Update Ansible') {
            steps {
                script {
                    def publicIp = sh(script: "cd /mnt/terraform && terraform output -json | jq -r '.instance_public_ip.value'", returnStdout: true).trim()
                    echo "Public IP: ${publicIp}"

                    // Update Ansible hosts file
                    writeFile file: '/mnt/terraform/ansible/hosts', text: """
                    [webservers]
                    ${publicIp}
                    """

                    echo "Fixing permissions for SSH key..."
                    sh '''
                    sudo chmod 400 /mnt/terraform/uswest.pem
                    sudo chown jenkins:jenkins /mnt/terraform/uswest.pem
                    '''

                    echo "Waiting 30 seconds for the instance to be ready..."
                    sleep(30)

                    echo "Visit the instance: http://${publicIp}"
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    sh '''
                    export ANSIBLE_HOST_KEY_CHECKING=False
                    ansible-playbook -i /mnt/terraform/ansible/hosts --private-key /mnt/terraform/uswest.pem -u ubuntu /mnt/terraform/ansible/httpd.yml
                    '''
                }
            }
        }

        stage('Approval Before Destroy') {
            steps {
                script {
                    def publicIp = sh(script: "cd /mnt/terraform && terraform output -json | jq -r '.instance_public_ip.value'", returnStdout: true).trim()
                    input message: "Visit the instance: http://${publicIp}\n\nHave you checked the website? Do you want to destroy the instance?",
                          parameters: []
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                dir("/mnt/terraform") {
                    sh 'terraform destroy --auto-approve'
                }
            }
        }
    }
}
