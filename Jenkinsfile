pipeline {
    agent any

    stages {
        stage('Pre-Cleanup') {
            steps {
                sh 'docker volume rm 03pyff.etc_pki_sign 03pyff.etc_pyff 03pyff.home_pyff03_ssh 03pyff.var_log 03pyff.var_md_feed 03pyff.var_md_source'
            }
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
        stage('Post-Cleanup') {
            steps {
                sh 'docker volume rm 03pyff.etc_pki_sign 03pyff.etc_pyff 03pyff.home_pyff03_ssh 03pyff.var_log 03pyff.var_md_feed 03pyff.var_md_source'
            }
        }
    }
}
