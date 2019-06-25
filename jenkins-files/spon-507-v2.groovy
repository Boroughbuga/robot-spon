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
        stage ('cloning form github') {
          sh'''
            sudo apt install git
            cd /home/cord/ilgaz
            rm -rf robot-spon
            git clone  "https://github.com/borougbuga/robot-spon.git"
          '''
        }
        stage ('pip & robot framework installation') {
          sh'''
                yes | sudo apt install python-pip
                sudo pip install robotframework
          '''

        }
        stage ('required libraries for robot-tests') {
          sh'''
                sudo pip install --upgrade robotframework-sshlibrary
                sudo pip install -U requests
                sudo pip install -U robotframework-requests
          '''
        }
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
