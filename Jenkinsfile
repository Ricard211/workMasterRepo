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
                // 1. Look up the CodeQL installation named "CodeQL" in Global Tool Config
                def codeqlHome = tool 'CodeQL'
                // 2. Prepend its bin folder to PATH and run your script inside that env
                withEnv(["PATH=${codeqlHome}/bin:${env.PATH}"]) {
                    sh './run_sast.sh'
                }
                }
            }
        }
    }
}
