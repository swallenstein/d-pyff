pipeline {
    agent any

    stages {
        stage('Get repo') {
            steps {
                sh '''
                echo 'Updating submodule ..'
                git submodule update --init
                cd dscripts && git checkout master && git pull && cd ..
                '''
            }
        }
        stage('Build') {
            steps {
                sh '''
                echo 'Building ..'
                rm conf.sh || true
                ln -s conf.sh.default conf.sh
                source conf.sh
                docker rm --force $CONTAINERNAME || true
                ./dscripts/build.sh
                '''
            }
        }
        stage('Test') {
            steps {
                sh '''
                echo 'Testing ..'
                ./dscripts/run.sh -p
                '''
            }
        }
    }
}
