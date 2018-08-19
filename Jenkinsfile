// Build-Setup-Test (no prior cleanup; leave container running after test)

pipeline {
    agent any
    options { disableConcurrentBuilds() }
    parameters {
        string(description: '"True": "Set --nocache for docker build; otherwise leave empty', name: 'nocache')
        string(description: '"True": push docker image after build; otherwise leave empty', name: 'pushimage')
    }

    stages {
        stage('Build') {
            steps {
                echo "==========================="
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'DockerRepoUpload',
                                  usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    sh '''
                        [[ "$nocache" ]] && nocacheopt='-c'
                        [[ "$pushimage" ]] && pushopt='-p'
                        export MANIFEST_SCOPE=local
                        ./dcshell/build -f dc.yaml $nocacheopt $pushopt
                        echo "=== build completed with rc $?"
                    '''
                }
            }
        }
        stage('Test ') {
            steps {
                sh '''
                    echo 'Testing..'
                    export REPO_HOST='localhost'  #  for ssh-config only, no test yet
                    docker-compose -f dc-yml run --rm pyff /tests/test_all.sh
                '''
            }
        }
    }
}
