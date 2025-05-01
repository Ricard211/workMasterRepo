pipeline {
    agent any

    stages {
        stage('Build image and generate hash') {
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
                    // Try to copy image-hash.txt from the last successful build
                    try {
                        copyArtifacts(
                            projectName: env.JOB_NAME,
                            selector: [$class: 'StatusBuildSelector', stable: false, successful: true],
                            filter: 'image-hash.txt',
                            target: 'previous'
                        )
                        echo "🔍 Comparing current and previous image hashes..."

                        sh '''
                            echo "Previous hash:"
                            cat previous/image-hash.txt || echo "No previous hash"

                            echo "Current hash:"
                            cat image-hash.txt

                            if cmp -s image-hash.txt previous/image-hash.txt; then
                                echo "✅ Docker image hash is the same as previous build."
                            else
                                echo "⚠️ Docker image hash has changed since the last build."
                            fi
                        '''
                    } catch (Exception e) {
                        echo "ℹ️ No previous build artifact available for comparison."
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
