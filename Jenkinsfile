pipeline {
    agent any

    stages {
        stage('Run SAST (Semgrep)') {
            steps {
                echo "🔐 Running Semgrep and generating reports..."
                sh '''
                    chmod +x convert_semgrep_report.sh

                    mkdir -p reports

                    docker run --rm -v $PWD:/src returntocorp/semgrep semgrep \
                        scan --config=auto \
                        --output /src/reports/semgrep-report.json \
                        --json

                    bash convert_semgrep_report.sh

                    echo "📁 Final reports folder:"
                    ls -l reports
                '''
            }
        }


        stage('Build Docker images') {
            steps {
                sh 'bash build_images.sh'
            }
        }

        stage('Run containers') {
            steps {
                sh 'bash run_containers.sh'
            }
        }

        stage('Compare hashes') {
            steps {
                script {
                    try {
                        copyArtifacts(
                            projectName: env.JOB_NAME,
                            selector: [$class: 'StatusBuildSelector', stable: false, successful: true],
                            filter: 'image-hash.txt',
                            target: 'previous'
                        )
                        sh 'bash compare_hashes.sh'
                    } catch (Exception e) {
                        echo "ℹ️ No previous build hash to compare."
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh 'bash stop_and_clean.sh'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'image-hash.txt', fingerprint: true
            archiveArtifacts artifacts: 'reports/semgrep-report.json'
            archiveArtifacts artifacts: 'reports/semgrep-report.html'
        }
    }
}
