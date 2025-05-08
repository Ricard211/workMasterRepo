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
    }
}
