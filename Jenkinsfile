pipeline {
  agent {
    any
  }
  stages {
    stage('Test') {
      steps {
        sh 'docker version'
        sh 'node --version'
        sh 'ls -l'
        sh 'sh process.sh'
      }
    }
  }
}