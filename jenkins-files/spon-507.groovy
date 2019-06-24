        try {
            stage ('cloning form github') {
                sudo apt install git
                cd ilgaz
                git clone  https://@github.com/borougbuga/robot-spon.git.git"
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

            currentBuild.result = 'SUCCESS'
        } catch (err) {
            currentBuild.result = 'FAILURE'
        }
        echo "RESULT: ${currentBuild.result}"

