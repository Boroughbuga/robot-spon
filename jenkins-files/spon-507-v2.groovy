pipeline {
    parameters {
        [$class: 'TextParameterDefinition', defaultValue: 'jboss', description: 'Image Name', name: 'IMAGE_NAME'],
        booleanParam(defaultValue: true, description: '', name: 'userFlag')
        string(
                $whichNode: 'yo',
                name: 'whichNode',
                defaultValue: "192.168.31.181",
                description: 'where do you want to run pipeline?',
         )
        choice(
                name: 'test1:run-check-nodesS',
                choices: "yes\nno",
                description: 'choose yes to run the test' )
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
            expression { 'test1:run-check-nodesS' == 'yes' }
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