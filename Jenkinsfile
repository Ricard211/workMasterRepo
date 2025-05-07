pipeline {
    agent any

    stages {
        stage('Check Git Changes') {
            steps {
                script {
                def changes = sh(script: 'git diff --name-only HEAD~1 HEAD', returnStdout: true).trim()
                echo "Changed files:\n${changes}"
                }
            }
        }

        stage('Run SAST (Semgrep on changed files)') {
            steps {
                sh '''
                    # 1. Capture changed files between this commit and the last successful build
                    git diff --name-only origin/${GIT_PREVIOUS_SUCCESSFUL_COMMIT} HEAD \
                        > changed-files.txt

                    # 2. Filter to code files
                    CHANGED=$(grep -E '\\.(php|html|js|py|sh)$' changed-files.txt || true)

                    mkdir -p reports/semgrep

                    if [ -z "$CHANGED" ]; then
                        echo "🟢 No changed source files to scan with Semgrep."
                        # Write a valid empty JSON so later stages don't break
                        echo '{"results":[]}' > reports/semgrep/semgrep-report.json
                    else
                        echo "📂 Running Semgrep on changed files:"
                        echo "$CHANGED"

                        docker run --rm -v "$PWD:/src" returntocorp/semgrep semgrep scan \
                        --config=/src/.semgrep.yml \
                        --config=p/owasp-top-ten \
                        --json --output /src/reports/semgrep/semgrep-report.json \
                        $CHANGED || true
                    fi

                    # (Optional) Convert to HTML if you still need it
                    bash convert_semgrep_report.sh reports/semgrep/semgrep-report.json
                '''
            }
        }


        stage('Build Docker images') {
            steps {
                sh 'bash build_images.sh'
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

        stage('Run containers') {
            steps {
                sh 'bash run_containers.sh'
            }
        }

        stage('Run DAST (OWASP ZAP Full Scan)') {
            steps {
                echo "🌐 Scanning only changed containers..."

                sh '''
                mkdir -p reports

                while read i; do
                    PORT=$((8080 + i))
                    echo "🔍 Scanning container $i on http://localhost:$PORT..."

                    docker run --rm --network="host" \
                    -v "$PWD/reports:/zap/wrk" \
                    -v "$PWD/reports:/tmp/reports" \
                    zaproxy/zap-stable \
                    zap-full-scan.py \
                    -t http://localhost:$PORT \
                    -r /tmp/reports/zap-report-$PORT.html \
                    -J /tmp/reports/zap-report-$PORT.json || true
                done < changed-containers.txt
                '''
            }
        }


        stage('Merge ZAP JSON Reports') {
            steps {
                echo "📦 Merging ZAP JSON reports into one file..."
                sh '''
                    jq -s '{ site: map(.site[]) }' reports/zap-report-*.json > reports/zap-report-combined.json
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

        stage('Cleanup') {
            steps {
                sh 'bash stop_and_clean.sh'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'image-hash.txt', fingerprint: true
            archiveArtifacts artifacts: 'reports/semgrep/semgrep-report.json'
            archiveArtifacts artifacts: 'reports/semgrep-report.html'
            archiveArtifacts artifacts: 'reports/security-report.html'
            archiveArtifacts artifacts: 'reports/zap-report-combined.json'
            archiveArtifacts artifacts: 'reports/sast/**/*.*', allowEmptyArchive: true
        }
    }
}
