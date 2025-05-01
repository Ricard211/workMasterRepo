pipeline {
    agent any
    stages {
        stage('Run process.sh') {
            steps {
                sh '''
                    chmod +x process.sh
                    bash process.sh
                '''
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'image-hash.txt', fingerprint: true
        }
    }
}
