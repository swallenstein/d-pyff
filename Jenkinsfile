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
                sh '''
                    rm conf.sh 2> /dev/null || true
                    cp conf.sh.default conf.sh
                    ./dscripts/manage.sh rm 2>/dev/null || true
                    ./dscripts/manage.sh rmvol 2>/dev/null || true
                '''
            }
        }
        stage('Build') {
            steps {
                echo "==========================="
                sh 'set +x; source ./conf.sh; echo "Building $IMAGENAME"'
                echo "Pipeline args: nocache=$nocache; pushimage=$pushimage; docker_registry_user=$docker_registry_user; docker_registry_host=$docker_registry_host"
                echo "==========================="
                sh '''
                    set +x
                    echo [[ "$docker_registry_user" ]] && echo "DOCKER_REGISTRY_USER $docker_registry_user"  > local.conf
                    echo [[ "$docker_registry_host" ]] && echo "DOCKER_REGISTRY_HOST $docker_registry_host"  >> local.conf
                    source ./conf.sh
                    [[ "$pushimage" ]] && pushopt='-P'
                    [[ "$nocache" ]] && nocacheopt='-c'
                    ./dscripts/build.sh -p $nocacheopt $pushopt
                    echo "=== build completed with rc $?"
                '''
                sh '''
                    echo "generate run script"
                    ./dscripts/run.sh -w
                '''
            }
        }
        stage('Test ') {
            steps {
                sh '''
                    echo 'Testing..'
                    ./dscripts/run.sh -iV /tests/test_all.sh
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
