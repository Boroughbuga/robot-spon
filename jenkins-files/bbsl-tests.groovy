pipeline {
    parameters {
        string(
                name: 'whichNode',
                defaultValue: "tt-pod",
                description: 'where do you want to run pipeline? ex: tt-pod, 192.168.31.181, 192.168.31.200')
        string(
                name: 'installdir',
                defaultValue: "jenkins/robot",
                description: 'where do you want to install? ex: jenkins/robot')
        string(
                name: 'branch2clone',
                defaultValue: "master",
                description: 'which branch are you using? ex: v1, master, anydesktest')
        choice(
                name: 'installrobot',
                choices: "yes\nno",
                description: 'choose yes to install robot and its libraries if you havent already')
        choice(
                name: 'test1',
                choices: "yes\nno",
                description: 'test1:BBSL check if chassis list is empty.Choose yes to run the test')
        choice(
                name: 'test2',
                choices: "yes\nno",
                description: 'test2: BBSL add OLT without chassis.Choose yes to run the test')
        choice(
                name: 'test3',
                choices: "yes\nno",
                description: 'test3:BBSL add chassis.Choose yes to run the test')
        choice(
                name: 'test4',
                choices: "yes\nno",
                description: 'test4:BBSL get chassis.Choose yes to run the test')
        choice(
                name: 'test5',
                choices: "yes\nno",
                description: 'test5:BBSL add OLTs.Choose yes to run the test')
        choice(
                name: 'test6',
                choices: "yes\nno",
                description: 'test6:BBSL check OLTs.Choose yes to run the test')
        choice(
                name: 'test7',
                choices: "yes\nno",
                description: 'test7:BBSL Provision ONTs.Choose yes to run the test')
        choice(
                name: 'test8',
                choices: "yes\nno",
                description: 'test8: BBSL Check ONTs.Choose yes to run the test')
        choice(
                name: 'test9',
                choices: "yes\nno",
                description: 'test9: BBSL Disable ONTs.Choose yes to run the test')
        choice(
                name: 'test10',
                choices: "yes\nno",
                description: 'test10: BBSL Enable ONTs.Choose yes to run the test')
        choice(
                name: 'test11',
                choices: "yes\nno",
                description: 'test11: BBSL Add Technology profiles.Choose yes to run the test')
        choice(
                name: 'test12',
                choices: "yes\nno",
                description: 'test12: BBSL Add Speed profiles.Choose yes to run the test')
        choice(
                name: 'test13',
                choices: "yes\nno",
                description: 'test13: BBSL Provision subscriber.Choose yes to run the test')
        choice(
                name: 'publish_report',
                choices: "yes\nno",
                description: 'test14: Publish test reports from jenkins?')
    }
    agent {
        node params.whichNode
    }
    stages {
        stage('cloning from github') {
            steps {
                sh """
                sudo apt install git
                cd /home/${params.installdir}
                rm -rf robot-spon
                git clone -b ${params.branch2clone} "https://github.com/borougbuga/robot-spon.git"
                """
            }
        }
        stage('pip & robot framework installation') {
            when {
                expression { params.installrobot == 'yes' }
            }
            steps {
                sh """
                yes | sudo apt install python-pip
                sudo pip install robotframework
                """
            }
        }
        stage('required libraries for robot-tests') {
            when {
                expression { params.installrobot == 'yes' }
            }
            steps {
                sh """
                sudo pip install --upgrade robotframework-sshlibrary
                sudo pip install -U requests
                sudo pip install -U robotframework-requests
                """
            }
        }
        stage('test1: BBSL check if chassis list is empty') {
            when {
                expression { params.test1 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test1 bbsl-tests.robot
                        """
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
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test2 bbsl-tests.robot
                        """
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
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test3 bbsl-tests.robot
                        """
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
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test4 bbsl-tests.robot
                        """
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
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test5 bbsl-tests.robot
                        """
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
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test6 bbsl-tests.robot
                        """
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
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test7 bbsl-tests.robot
                        """
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
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test8 bbsl-tests.robot
                        """
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
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test9 bbsl-tests.robot
                        """
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
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test10 bbsl-tests.robot
                        """
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
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test11 bbsl-tests.robot
                        """
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
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test12 bbsl-tests.robot
                        """
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
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test13 bbsl-tests.robot
                        """
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }
        stage('Publish Robot results') {
            when {
                expression { params.publish_report == 'yes' }
            }
            steps {
                script {
                    step(
                            [
                                    $class              : 'RobotPublisher',
                                    outputPath          : "/home/${params.installdir}/robot-spon/tests/test_logs",
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
