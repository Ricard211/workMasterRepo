pipeline {
    agent any

    stages {
        stage('Run SAST (Semgrep)') {
            steps {
                echo "🔐 Running Semgrep (custom + OWASP) on src/html1 to html5..."

                sh '''
                    mkdir -p reports

                    docker run --rm -v $PWD:/src returntocorp/semgrep semgrep \
                        scan \
                        --config=/src/.semgrep.yml \
                        --config=p/owasp-top-ten \
                        --json \
                        --output /src/reports/semgrep-report.json \
                        /src/src/html1 /src/src/html2 /src/src/html3 /src/src/html4 /src/src/html5 || true

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

        stage('Run DAST (OWASP ZAP Full Scan)') {
            steps {
                echo "🌐 Running ZAP scans using zaproxy/zap-stable..."
                sh '''
                    mkdir -p reports

                    for i in 1 2 3 4 5; do
                      PORT=$((8080 + i))
                      echo "🔍 Scanning http://localhost:$PORT..."

                      docker run --rm --network="host" \
                        -v "$PWD/reports:/zap/wrk" \
                        -t zaproxy/zap-stable \
                        zap-full-scan.py \
                        -t http://localhost:$PORT \
                        -r zap-report-$PORT.html \
                        -J zap-report-$PORT.json || true
                    done
                '''
            }
        }

        stage('Generate Unified Security Report') {
            steps {
                echo "📊 Combining Semgrep + ZAP into unified HTML..."
                sh '''
                    chmod +x generate_unified_report.sh
                    bash generate_unified_report.sh
                '''
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
            archiveArtifacts artifacts: 'reports/security-report.html'
            archiveArtifacts artifacts: 'reports/zap-report-*.json'
            archiveArtifacts artifacts: 'reports/zap-report-*.html'
        }
    }
}
