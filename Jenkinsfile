// Build-Setup-Test (no prior cleanup; leave container running after test)

pipeline {
    agent any
    options { disableConcurrentBuilds() }
    parameters {
        string(defaultValue: 'True', description: '"True": initial cleanup: remove container and volumes; otherwise leave empty', name: 'start_clean')
        string(description: '"True": "Set --nocache for docker build; otherwise leave empty', name: 'nocache')
        string(description: '"True": push docker image after build; otherwise leave empty', name: 'pushimage')
        string(description: '"True": keep running after test; otherwise leave empty to delete container and volumes', name: 'keep_running')
        string(description: '"True": overwrite default docker registry user; otherwise leave empty', name: 'docker_registry_user')
        string(description: '"True": overwrite default docker registry host; otherwise leave empty', name: 'docker_registry_host')
    }

    stages {
        stage('docker cleanup') {
            steps {
                sh '''
                    rm conf.sh 2> /dev/null || true
                    cp conf.sh.default conf.sh
                    if [[ "$start_clean" ]]; then
                        ./dscripts/manage.sh rm 2>/dev/null || true
                        ./dscripts/manage.sh rmvol 2>/dev/null || true
                    fi
                '''
            }
        }
        stage('Build') {
            steps {
                echo "==========================="
                sh 'set +x; source ./conf.sh; echo "Building $IMAGENAME"'
                echo "Pipeline args: nocache=$nocache; pushimage=$pushimage; docker_registry_user=$docker_registry_user; docker_registry_host=$docker_registry_host"
                echo "==========================="
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'DockerRepoUpload',
                                  usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    sh '''
                        if [[ "$docker_registry_user" != "$USERNAME" ]]; then
                            echo "User name in Jenkins credential 'DockerRepoUpload' and $docker_registry_user do not match"
                            exit 1
                        fi

                        # Login works, but push results in "no basic auth credentials"
                        #docker login -u $docker_registry_user -p $PASSWORD $docker_registry_host
                        set +x
                        echo [[ "$docker_registry_user" ]] && echo "DOCKER_REGISTRY_USER $docker_registry_user"  > local.conf
                        echo [[ "$docker_registry_host" ]] && echo "DOCKER_REGISTRY_HOST $docker_registry_host"  >> local.conf
                        source ./conf.sh
                        [[ "$pushimage" ]] && pushopt='-P'
                        [[ "$nocache" ]] && nocacheopt='-c'
                        ./dscripts/build.sh -p $nocacheopt $pushopt
                        echo "=== build completed with rc $?"
                    '''
                }
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
                    export REPO_HOST='localhost'  #  for ssh-config only, no test yet
                    ./dscripts/run.sh -iV /tests/test_all.sh
                '''
            }
        }
    }
    post {
        always {
            sh '''
                if [[ "$keep_running" ]]; then
                   echo "Keep container running"
                else
                    echo 'Removing container, volumes'
                    ./dscripts/manage.sh rm 2>/dev/null || true
                    ./dscripts/manage.sh rmvol 2>/dev/null || true
                fi
            '''
        }
    }
}
