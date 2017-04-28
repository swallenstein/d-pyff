pipeline {
    agent any

    stages {
        stage('Get repo') {
            steps {
                sh '''
                echo 'Updating submodule'
                git submodule update --init
                cd dscripts && git checkout master && git pull && cd ..
                '''
            }
        }
        stage('Build') {
            steps {
                sh '''
                echo 'Building..'
                docker rm --force identidock || true
                rm conf.sh || true
                ln -s conf.sh.default conf.sh
                ./dscripts/build.sh
                '''
            }
        }
        stage('Test') {
            steps {
                sh '''
                echo 'Testing..'
                ./dscripts/run.sh -I python tests.py
                '''
            }
        }
    }
}
