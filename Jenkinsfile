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

        stage('Compare with previous hash') {
            steps {
                copyArtifacts(
                    projectName: env.JOB_NAME,
                    selector: [$class: 'StatusBuildSelector', stable: false, successful: true],
                    filter: 'image-hash.txt',
                    target: 'previous'
                )

                sh '''
                    echo "🔍 Previous hash:"
                    cat previous/image-hash.txt || echo "No previous hash"

                    echo "🔍 Current hash:"
                    cat image-hash.txt

                    if cmp -s image-hash.txt previous/image-hash.txt; then
                        echo "✅ Docker image hash is the same as previous build."
                    else
                        echo "⚠️ Docker image hash has changed since the last build."
                    fi
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
