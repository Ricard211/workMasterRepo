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
                script {
                // 1. Locate the CodeQL installation named “CodeQL” in Global Tool Configuration
                def codeqlHome = tool 'CodeQL'

                // 2. Invoke the script with CODEQL_HOME set, so run_sast.sh can find the binary
                withEnv(["CODEQL_HOME=${codeqlHome}", "PATH+CODEQL=${codeqlHome}/bin"]) {
                    // If your script isn’t executable, call via bash
                    sh 'bash run_sast.sh'
                }
                }
            }
        }


    }
}
