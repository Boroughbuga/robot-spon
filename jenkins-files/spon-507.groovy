node ("${podName}") {
    parameters {
        choice(
                choices: ['greeting' , 'silence'],
                description: '',
                name: 'REQUESTED_ACTION')
    }
    stage('Sanity check') {
        when {
            // Only say hello if a "greeting" is requested
            expression { params.REQUESTED_ACTION == 'greeting' }
        }
        input "Ready to start?"
    }
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
}


