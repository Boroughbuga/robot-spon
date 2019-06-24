node ("${podName}") {
    stages {
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
    }
}

