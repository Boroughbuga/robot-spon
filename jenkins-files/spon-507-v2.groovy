pipeline {
    agent {
        node {
            label '${podName}'
        }
    }
    parameters {
        choice(
                name: 'test1:run-check-nodes',
                choices: "yes\nno",
                description: 'choose yes to run the test' )    }
    stages {
        when {
            expression { test1:run-check-nodes == 'yes' }
        }
        stage('Build') {
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