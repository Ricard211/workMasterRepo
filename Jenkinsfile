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
                # Determine the “base” for diff
                PREV_COMMIT="${GIT_PREVIOUS_SUCCESSFUL_COMMIT:-}"
                if [ -n "$PREV_COMMIT" ] && git rev-parse --verify "$PREV_COMMIT" >/dev/null 2>&1; then
                    BASE="$PREV_COMMIT"
                else
                    echo "⚠️ Previous commit not found; falling back to HEAD~1"
                    BASE="HEAD~1"
                fi

                # List changed files between BASE and HEAD
                git diff --name-only "$BASE" HEAD -- > changed-files.txt

                # Filter to source extensions
                CHANGED=$(grep -E '\\.(php|html|js|py|sh)$' changed-files.txt || true)

                mkdir -p reports/semgrep

                if [ -z "$CHANGED" ]; then
                    echo "🟢 No changed source files to scan with Semgrep."
                    # Write an empty but valid Semgrep JSON
                    echo '{"results":[]}' > reports/semgrep/semgrep-report.json
                else
                    echo "📂 Running Semgrep on changed files:"
                    echo "$CHANGED"

                    docker run --rm -v "$PWD:/src" returntocorp/semgrep semgrep scan \
                    --config=/src/.semgrep.yml \
                    --config=p/owasp-top-ten \
                    --config=r/all \
                    --config=r/security-audit \
                    --config=r/ci-cd \
                    --config=r/ci-cd-aws \
                    --config=r/ci-cd-gcp \
                    --config=r/ci-cd-azure \
                    --config=r/ci-cd-azure-pipelines \
                    --config=r/ci-cd-azure-pipelines-2 \
                    --config=r/ci-cd-azure-devops \
                    --config=r/ci-cd-azure-devops-2 \
                    --config=r/ci-cd-github-actions \
                    --config=r/ci-cd-gitlab-ci \
                    --config=r/ci-cd-gitlab-ci-2 \
                    --config=r/ci-cd-jenkins \
                    --config=r/ci-cd-jenkinsfile \
                    --config=r/ci-cd-jenkinsfile-2 \
                    --config=r/ci-cd-jenkinsfile-3 \
                    --config=r/ci-cd-jenkinsfile-4 \
                    --config=r/ci-cd-jenkinsfile-5 \

                    --json --output /src/reports/semgrep/semgrep-report.json \
                    $CHANGED || true
                fi

                # Convert JSON to HTML if needed
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
