// Build-Setup-Test (no prior cleanup; leave container running after test)

pipeline {
    agent any
    options { disableConcurrentBuilds() }
    parameters {
        string(defaultValue: 'True', description: '"True": initial cleanup: remove container and volumes; otherwise leave empty', name: 'start_clean')
        string(description: '"True": "Set --nocache for docker build; otherwise leave empty', name: 'nocache')
        string(description: '"True": push docker image after build; otherwise leave empty', name: 'pushimage')
        string(description: '"True": keep running after test; otherwise leave empty to delete container and volumes', name: 'keep_running')
    }

    stages {
        stage('Job Env') {
            steps {
                sh '''
                    set +x
                    echo "Build parameters:"
                    echo "  nocache=$nocache"
                    echo "  DOCKER_REGISTRY_USER=$DOCKER_REGISTRY_USER"
                    echo "Push parameters:"
                    echo "  pushimage=$pushimage"
                    if [[ "$pushimage" ]]; then
                        default_registry=$(docker info 2> /dev/null |egrep '^Registry' | awk '{print $2}')
                        echo "  Docker default registry: $default_registry"
                    fi
                '''
            }
        }
        stage('Cleanup ') {
            steps {
                sh '''
                if [[ ! "$start_clean" ]]; then
                    echo 'removing docker volumes and container (tests need initial data to pass)'
                    docker-compose -f dc.yaml down -v 2>/dev/null | true
                fi
                '''
            }
        }
        stage('Build') {
            steps {
                echo "==========================="
                    sh '''
                        [[ "$nocache" ]] && nocacheopt='-c'
                        export MANIFEST_SCOPE=local
                        ./dcshell/build -f dc.yaml $nocacheopt
                        echo "=== build completed with rc $?"
                    '''
                //}
            }
        }
        stage('Test ') {
            steps {
                sh '''
                    echo 'Testing..'
                    export REPO_HOST='localhost'  #  for ssh-config only, no test yet
                    docker-compose -f dc.yaml run --rm pyff /tests/test_all.sh
                '''
            }
        }
        stage('Push ') {
            when {
                expression { params.pushimage?.trim() != '' }
            }
            steps {
                sh 'docker-compose -f dc.yaml push pyff'
            }
        }
    }
    post {
        always {
            sh '''
                if [[ ! "$keep_running" ]]; then
                    echo 'removing docker volumes and container'
                    docker-compose -f dc.yaml down -v
                fi
            '''
        }
    }
}
