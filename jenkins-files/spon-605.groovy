pipeline {
    parameters {
        string(
                name: 'whichNode',
                defaultValue: "192.168.31.181",
                description: 'where do you want to run pipeline?')
        choice(
                name: 'installrobot',
                choices: "no\nyes",
                description: 'choose yes to install robot and its libraries if you havent already')
        choice(
                name: 'test1',
                choices: "no\nyes",
                description: 'test1:BBSL check if chassis list is empty.Choose yes to run the test')
        choice(
                name: 'test2',
                choices: "no\nyes",
                description: 'test2: BBSL add OLT without chassis.Choose yes to run the test')
        choice(
                name: 'test3',
                choices: "no\nyes",
                description: 'test3:BBSL add chassis.Choose yes to run the test')
        choice(
                name: 'test4',
                choices: "no\nyes",
                description: 'test4:BBSL get chassis.Choose yes to run the test')
        choice(
                name: 'test5',
                choices: "no\nyes",
                description: 'test5:BBSL add OLT.Choose yes to run the test')
        choice(
                name: 'test6',
                choices: "no\nyes",
                description: 'test6:BBSL check OLT.Choose yes to run the test')
        choice(
                name: 'test7',
                choices: "no\nyes",
                description: 'test7:BBSL Provision ONT.Choose yes to run the test')
        choice(
                name: 'test8',
                choices: "no\nyes",
                description: 'test8: BBSL Check ONT.Choose yes to run the test')
        choice(
                name: 'test9',
                choices: "no\nyes",
                description: 'test9: BBSL Disable ONT.Choose yes to run the test')
        choice(
                name: 'test10',
                choices: "no\nyes",
                description: 'test10: BBSL Enable ONT.Choose yes to run the test')
        choice(
                name: 'test11',
                choices: "no\nyes",
                description: 'test11: BBSL Add Technology profile.Choose yes to run the test')
        choice(
                name: 'test12',
                choices: "no\nyes",
                description: 'test12: BBSL Add Speed profile.Choose yes to run the test')
        choice(
                name: 'test13',
                choices: "no\nyes",
                description: 'test13: BBSL Provision subscriber.Choose yes to run the test')
        choice(
                name: 'test14',
                choices: "no\nyes",
                description: 'test14: BBSL Provision subscriber.Choose yes to run the test')
    }
    agent {
        node 'whichNode'
    }
    stages {
        stage('cloning from github') {
            steps {
                sh '''
                sudo apt install git
                cd /home/cord/ilgaz
                rm -rf robot-spon
                git clone  "https://github.com/borougbuga/robot-spon.git"
                '''
            }
        }
        stage('pip & robot framework installation') {
            when {
                expression { params.installrobot == 'yes' }
            }
            steps {
                sh '''
                yes | sudo apt install python-pip
                sudo pip install robotframework
                '''
            }
        }
        stage('required libraries for robot-tests') {
            when {
                expression { params.installrobot == 'yes' }
            }
            steps {
                sh '''
                sudo pip install --upgrade robotframework-sshlibrary
                sudo pip install -U requests
                sudo pip install -U robotframework-requests
                '''
            }
        }
        stage('test1: BBSL check if chassis list is empty') {
            when {
                expression { params.test1 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test1 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test2: BBSL add OLT without chassis') {
            when {
                expression { params.test2 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test2 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test3: BBSL add chassis') {
            when {
                expression { params.test3 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test3 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test4: BBSL get chassis') {
            when {
                expression { params.test4 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test4 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test5: BBSL add OLT') {
            when {
                expression { params.test5 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test5 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test6: BBSL check OLT') {
            when {
                expression { params.test6 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test6 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test7: BBSL Provision ONT') {
            when {
                expression { params.test7 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test7 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test8: BBSL Check ONT') {
            when {
                expression { params.test8 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test8 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test9: BBSL Disable ONT') {
            when {
                expression { params.test9 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test9 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test10: BBSL Enable ONT') {
            when {
                expression { params.test10 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test10 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test11: BBSL Add Technology profile') {
            when {
                expression { params.test11 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test11 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test12: BBSL Add Speed profile') {
            when {
                expression { params.test12 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test12 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test13: BBSL Provision subscriber') {
            when {
                expression { params.test13 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test13 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('test14: BBSL Provision subscriber') {
            when {
                expression { params.test14 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh '''
                        cd /home/cord/ilgaz/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test14 spon-605.robot
                        '''
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }

        stage('Publish Robot results') {
            steps {
                script {
                    step(
                            [
                                    $class              : 'RobotPublisher',
                                    outputPath          : '../../ilgaz/robot-spon/tests/test_logs/',
                                    outputFileName      : "output*",
                                    reportFileName      : 'report*',
                                    logFileName         : 'log*',
                                    disableArchiveOutput: false,
                                    passThreshold       : 100,
                                    unstableThreshold   : 50.0,
                                    otherFiles          : "**/*.png,**/*.jpg",
                            ]
                    )
                }
            }
        }
    }
}