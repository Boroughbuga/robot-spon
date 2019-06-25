pipeline {
    parameters {
        string(
                name: 'whichNode',
                defaultValue: "192.168.31.181",
                description: 'where do you want to run pipeline?',
         )
         choice(
                name: 'test1_check_nodes',
                choices: "yes\nno",
                description: 'choose yes to run the test' )
    }
    agent {
        node 'whichNode'
        }
    stages {
        stage('Build') {
        when {
            expression { params.test1_check_nodes == yes }
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
