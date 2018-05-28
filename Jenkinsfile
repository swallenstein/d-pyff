// Build-Setup-Test (no prior cleanup; leave container running after test)

pipeline {
    agent any
    options { disableConcurrentBuilds() }
    parameters {
        string(defaultValue: '', description: 'Force "docker build --nocache" (blank or 1)', name: 'nocache')
        string(description: 'push docker image after build (blank or 1)', name: 'pushimage')
        string(description: 'overwrite default docker registry user', name: 'docker_registry_user')
        string(description: 'overwrite default docker registry host', name: 'docker_registry_host')
    }

    stages {
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
                    ./dscripts/build.sh -n39 -p $nocacheopt $pushopt
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
