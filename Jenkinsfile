pipeline {
    agent {
        label('aws')
    }
    environment{
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    stages {
        stage('Init') {
            steps {
                dir('terraform') {
                   sh '''cd www
                    terraform init'''
                }
            }
        }
        stage('Plan') {
            steps {
                dir('terraform') {
                   sh '''cd www
                   terraform plan'''
                }
            }
        }
        stage('Apply') {
            input {
                message "Confirm deployment"
                ok "Deploying..."
            }
            when  {
                branch 'dev'
            }
            steps {
                dir('terraform') {
                     sh '''cd www
                     terraform apply -auto-approve'''
              }
            }
        }
        stage('Test') {
            agent {
               node {
                   label 'test'
               }
             }
           steps {
                dir('terraform') {
                   sh 'curl "kc-bucket-om.s3-website-eu-west-1.amazonaws.com"'
                }
            }
        }
    }
    post {
        failure {
            echo "There has been an error, check your configuration"
        }
        success {
            echo "Deployment completed"
        }
    }
}
