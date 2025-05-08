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
                sh 'bash run_sast.sh'
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
