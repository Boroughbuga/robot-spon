pipeline {
    parameters {
        string(
                name: 'whichNode',
                defaultValue: "192.168.31.181",
                description: 'where do you want to run pipeline?',
         )
         choice(
                name: 'test1:run-check-nodes',
                choices: "yes\nno",
                description: 'choose yes to run the test' )
    }
    agent {
        node 'whichNode'
        }
    stages {
        stage('Build') {
        when {
            expression { 'test1:run-check-nodes' == yes }
        }
            steps {
            cd /home/cord/ilgaz
            mkdir wazzup2
            }
        }
                stage('Build2') {
        when {
            expression { 'test1:run-check-nodes' == 'yes' }
        }
            steps {
            sh 'cd ilgaz'
            sh 'mkdir wazzup'
            }
        }
                stage('Build3') {
        when {
            expression { 'test1:run-check-nodes' == 'yes' }
        }
            steps {
            sh 'cd ilgaz'
            sh 'mkdir wazzup3'
            }
        }
    }
}
