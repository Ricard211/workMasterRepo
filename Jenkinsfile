tools {
  codeql 'CodeQL'
}

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
                // Look up the CodeQL installation named “CodeQL” in Global Tool Config
                // this returns its install directory, e.g. /var/jenkins_home/tools/CodeQL/2.25.3
                def codeqlHome = tool name: 'CodeQL', type: 'com.github.codeql.jenkins.CodeQLInstallation'

                // Prepend its bin/ directory to PATH so that `codeql` is found
                withEnv(["PATH+CODEQL=${codeqlHome}/bin"]) {
                    sh './run_sast.sh'
                }
                }
            }
        }

    }
}
