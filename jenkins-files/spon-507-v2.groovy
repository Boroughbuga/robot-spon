pipeline {
    parameters {
        string(
                name: 'whichNode',
                defaultValue: "192.168.31.181",
                description: 'where do you want to run pipeline?',
         )
        choice(
                name: 'test1',
                choices: "yes\nno",
                description: 'test1:check-nodes.Choose yes to run the test' )
    }
    agent {
        node 'whichNode'
        }
    stages {
        stage('Build') {
        when {
            expression { params.test1 == 'yes' }
        }
        steps {
            sh '''
            cd /home/cord/ilgaz
            mkdir wazzup2
            '''
            }
        }
    }
}
