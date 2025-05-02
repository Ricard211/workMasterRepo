pipeline {
    agent any

    stages {
        
        stage('Run SAST (Semgrep)') {
            steps {
                echo "🔐 Running Semgrep (custom + OWASP) on src/html1 to html5..."

                sh '''
                    mkdir -p reports

                    # Scan all HTML folders with both custom and OWASP rules
                    docker run --rm -v $PWD:/src returntocorp/semgrep semgrep \
                        scan \
                        --config=/src/.semgrep.yml \
                        --config=p/owasp-top-ten \
                        --json \
                        --output /src/reports/semgrep-report.json \
                        /src/src/html1 /src/src/html2 /src/src/html3 /src/src/html4 /src/src/html5

                    echo "📁 Contents of reports directory:"
                    ls -l reports

                    bash convert_semgrep_report.sh
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
