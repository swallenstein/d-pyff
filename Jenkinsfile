pipeline {
    agent any

    stages {
        stage('Git pull + branch + submodule') {
            steps {
                sh '''
                echo 'hard coding git branch - TODO: move this to the jenkins git plugin'
                git checkout master
                echo 'pulling updates'
                git pull
                git submodule update --init
                cd ./dscripts && git checkout master && git pull && cd ..
                '''
            }
        }
        stage('docker cleanup') {
            steps {
                sh './dscripts/manage.sh rm 2>/dev/null || true'
                sh './dscripts/manage.sh rmvol 2>/dev/null || true'
                sh 'sudo docker ps --all'
            }
        }
        stage('Build') {
            steps {
                sh '''
                echo 'Building..'
                rm conf.sh 2> /dev/null || true
                ln -s conf.sh.default conf.sh
                ./dscripts/build.sh
                '''
            }
        }
        stage('Test ') {
            steps {
                sh '''
                echo 'Testing..'
                ./dscripts/run.sh -IV /tests/test_all.sh
                '''
            }
        }
    }
    post {
        always {
            echo 'removing docker container and volumes'
            sh '''
            ./dscripts/manager.sh rm 2>&1
            ./dscripts/manage.sh rmvol 2>&1
            '''
        }
    }
}
