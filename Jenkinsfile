pipeline {
    agent any

    stages {
        stage('Build images and generate hashes') {
            steps {
                sh '''
                    chmod +x process.sh
                    bash process.sh
                '''
            }
        }

        stage('Compare hashes individually') {
            steps {
                script {
                    def previousExists = false

                    // Try to copy previous image-hash.txt
                    try {
                        copyArtifacts(
                            projectName: env.JOB_NAME,
                            selector: [$class: 'StatusBuildSelector', stable: false, successful: true],
                            filter: 'image-hash.txt',
                            target: 'previous'
                        )
                        previousExists = true
                    } catch (Exception e) {
                        echo "ℹ️ No previous hash file available for comparison."
                    }

                    // Compare line-by-line
                    if (previousExists) {
                        sh '''
                            echo "🔍 Comparing image hashes one by one..."

                            while IFS= read -r current_line || [ -n "$current_line" ]; do
                                image_name=$(echo "$current_line" | cut -d':' -f1 | xargs)
                                current_hash=$(echo "$current_line" | cut -d':' -f2- | xargs)

                                # Find matching image line in previous file
                                prev_line=$(grep "^$image_name:" previous/image-hash.txt || true)

                                if [ -n "$prev_line" ]; then
                                    prev_hash=$(echo "$prev_line" | cut -d':' -f2- | xargs)
                                    if [ "$current_hash" = "$prev_hash" ]; then
                                        echo "✅ $image_name hash MATCHES previous build."
                                    else
                                        echo "⚠️ $image_name hash CHANGED!"
                                    fi
                                else
                                    echo "🆕 $image_name is NEW in this build."
                                fi
                            done < image-hash.txt
                        '''
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
