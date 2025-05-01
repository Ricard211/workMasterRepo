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
                script {
                    if (currentBuild.previousBuild != null) {
                        copyArtifacts(
                            projectName: env.JOB_NAME,
                            selector: lastSuccessful(),
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
                    } else {
                        echo "ℹ️ No previous build to compare with."
                    }
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'image-hash.txt', fingerprint: true
        }
    }
}
