pipeline {
    agent any

    parameters {
        string(defaultValue: '', description: 'Force "docker build --nocache"', name: 'nocache')
        string(defaultValue: '', description: 'push docker image after build', name: 'pushimage')
    }

    stages {
        /*stage('Git pull + branch + submodule') {
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
        }*/
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
                    [[ "$pushimage" ]] && pushopt='-P'
                    [[ "$nocache" ]] && nocacheopt='-c'
                    ./dscripts/build.sh -p $nocacheopt $pushopt
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
            echo 'removing docker volumes'
            sh './dscripts/manage.sh rmvol 2>&1 || true'
        }
    }
}
