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
                description: 'test1:Check HSI flows from Volta CLI.Choose yes to run the test')
        choice(
                name: 'test2',
                choices: "yes\nno",
                description: 'test2:Check VOIP flows from Voltha CLI.Choose yes to run the test')
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
        stage('test1: HSI Flows from voltha') {
            when {
                expression { params.test1 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test1 flow-tests.robot
                        """
                    }
                    catch (all) {
                        echo "test failed"
                    }
                }
            }
        }
        stage('test2: VOIP Flows from voltha') {
            when {
                expression { params.test2 == 'yes' }
            }
            steps {
                script {
                    try {
                        sh """
                        cd /home/${params.installdir}/robot-spon/tests
                        robot -d test_logs --timestampoutputs -t test2 flow-tests.robot
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
