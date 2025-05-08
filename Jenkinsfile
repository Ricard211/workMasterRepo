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

            stage('Run Extended SAST Suite') {
                steps {
                    // this step injects the CodeQL CLI into PATH for the block
                    withCodeQL {
                    // now codeql is on PATH, so run_sast.sh will find it
                    sh 'bash run_sast.sh'
                    }
                }
            }
    }
}
