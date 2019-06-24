node ("${podName}") {

    stage('Sanity check') {
        input "Ready to start?"
    }
    stage ('cloning form github') {
        sh '''
            sudo apt install git
            cd /home/cord/ilgaz
            git clone  https://@github.com/borougbuga/robot-spon.git.git"
        '''
    }
    stage ('pip & robot framework installation') {
            sh '''
                sudo apt install python-pip
                sudo apt install robotframework
            '''
    }
    stage ('required libraries for robot-tests') {
            sh '''
                sudo pip install --upgrade robotframework-sshlibrary
                sudo pip install -U requests
                sudo pip install -U robotframework-requests
            '''
    }
}


