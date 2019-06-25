pipeline {
    parameters {
        choice(
                name: 'test1:run-check-nodes',
                choices: "yes\nno",
                description: 'choose yes to run the test' )
    }
    agent {
        node {
            label 'whichNode'
        }
    }
    stages {
        stage('Build') {
        when {
            expression { 'test1:run-check-nodes' == 'yes' }
        }
            steps {
                input "Ready to start?"
            }
        }
    }
}
post {
    always {
        echo 'Pipeline is over'
    }
    success {
        echo 'Tests ended'
    }
    failure {
        echo 'something went wrong in pipeline'
    }
}