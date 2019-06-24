node ("${podName}") {

    stage('Sanity check') {
        input "Ready to start?"
    }
    stage ('cloning form github') {
            sudo apt install git
            cd /home/cord/ilgaz
            sh git clone  https://github.com/borougbuga/robot-spon.git
    }
    stage ('pip & robot framework installation') {
                sudo apt install python-pip
                sudo apt install robotframework
    }
    stage ('required libraries for robot-tests') {
                sudo pip install --upgrade robotframework-sshlibrary
                sudo pip install -U requests
                sudo pip install -U robotframework-requests
    }
}


