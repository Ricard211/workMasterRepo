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
            // 1) Look up the CodeQL tool by name and inject it into PATH
            script {
            // This name (“CodeQL”) must match exactly what you set under
            // Manage Jenkins → Global Tool Configuration → CodeQL
            def codeqlHome = tool 'CodeQL'
            // Prepend its bin directory so `codeql` is on PATH
            env.PATH = "${codeqlHome}/bin:${env.PATH}"
            }

            // 2) Run your existing SAST script (which calls `codeql …`)
            sh './run_sast.sh'
        }

    }
}
