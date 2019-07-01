pipeline {
    parameters {
        string(
            name: 'whichNode',
            defaultValue: "192.168.31.181",
            description: 'where do you want to run pipeline?' )
        choice(
                name: 'installrobot',
                choices: "no\nyes",
                description: 'choose yes to install robot and its libraries if you havent already' )
        choice(
                name: 'test1',
                choices: "no\nyes",
                description: 'test1:check-nodes.Choose yes to run the test' )
        choice(
                name: 'test2',
                choices: "no\nyes",
                description: 'test2:check-pods.Choose yes to run the test' )
        choice(
                name: 'test3',
                choices: "no\nyes",
                description: 'test3:check-services.Choose yes to run the test' )
        choice(
                name: 'test4',
                choices: "no\nyes",
                description: 'test4:add chassis and add OLT from BBSL.Choose yes to run the test' )
        choice(
                name: 'test5',
                choices: "no\nyes",
                description: 'test5:check OLT status from VCLI.Choose yes to run the test' )
        choice(
                name: 'olt_choice',
                choices: "argela_olt\nankara_olt",
                description: 'test4:which OLT do you want to check?' )
    }
    agent {
        node 'whichNode'
        }
    try{
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
            stage('test1: check nodes') {
                when {
                    expression { params.test1 == 'yes' }
                }
                steps {
                    sh '''
                    cd /home/cord/ilgaz/robot-spon/tests
                    robot -d test_logs --timestampoutputs -t test1 spon-507.robot
                    '''
                }
            }

            stage('test2: check pods') {
                when {
                    expression { params.test2 == 'yes' }
                }
                steps {
                    sh '''
                    cd /home/cord/ilgaz/robot-spon/tests
                    robot -d test_logs --timestampoutputs -t test2 spon-507.robot
                    '''
                }
            }

            stage('test3: check services') {
                when {
                    expression { params.test3 == 'yes' }
                }
                steps {
                    sh '''
                    cd /home/cord/ilgaz/robot-spon/tests
                    robot -d test_logs --timestampoutputs -t test3 spon-507.robot
                    '''
                }
            }

            stage('test4: add chassis and add OLT from bbsl') {
                when {
                    expression { params.test4 == 'yes' }
                }
                steps {
                    sh '''
                    cd /home/cord/ilgaz/robot-spon/tests
                    robot -d test_logs --timestampoutputs -t test4 spon-507.robot                                       
                    '''
                }
            }

            stage('test5: check VCLI - OLT status') {
                when {
                    expression { params.test5 == 'yes' }
                }
                steps {
                    sh """
                    cd /home/cord/ilgaz/robot-spon/jenkins-inputs
                    echo ${params.olt_choice}>jenkins-inputs.txt
                    cd /home/cord/ilgaz/robot-spon/tests
                    robot -d test_logs --timestampoutputs -t test5 spon-507.robot
                    """
                }
            }
//        stage('Results') {
//            steps {
//                sh "cd /home/cord/ilgaz/robot-spon"
//                publishTestResults()
//            }
//        }
        }
    }
    catch(all){
        currentBuild.result = 'FAILURE'
    }
}
//void publishTestResults() {
//    step([
//            $class           : 'hudson.plugins.robot.RobotPublisher',
//            outputPath       : 'tests/test_logs',
//            passThreshold    : 100,
//            unstableThreshold: 100,
//            otherFiles       : '',
//            reportFileName   : '**//*report*.html',
//            logFileName      : '**//*log*.html',
//            outputFileName   : '**//*output*.xml'
//    ])
//}