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
                // inject CodeQL into PATH as before
                def codeqlHome = tool 'CodeQL'
                withEnv(["PATH=${codeqlHome}/bin:${env.PATH}"]) {
                    // invoke the script via bash, not via exec bit
                    sh 'bash run_sast.sh'
                }
                }
            }
        }

    }
}
