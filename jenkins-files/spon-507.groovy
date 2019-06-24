pipeline {
    agent any
    stages {
        stage('Sanity check') {
            steps {
                input "Ready to start?"
            }
        }
        stage ('cloning form github') {
            steps {
                sh '''
                    sudo apt install git
                    cd /home/cord/ilgaz
                    git clone  https://@github.com/borougbuga/robot-spon.git.git"
                '''
            }
        }
        stage ('pip & robot framework installation') {
            steps {
                sh '''
                    sudo apt install python-pip
                    sudo apt install robotframework
                '''
            }
        }
        stage ('required libraries for robot-tests') {
            steps {
                sh '''
                    sudo pip install --upgrade robotframework-sshlibrary
                    sudo pip install -U requests
                    sudo pip install -U robotframework-requests
                '''
            }
        }
    }
}
        success {
            echo 'pipeline completed'
        }
        failure {
            echo 'pipeline failed'
        }