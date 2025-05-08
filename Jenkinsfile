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
            // withCodeQL is provided by the CodeQL Jenkins plugin;
            // it makes the CodeQL CLI available on PATH inside the block.
            withCodeQL('CodeQL') {
            sh './run_sast.sh'
            }
            }
        }
    }
}
