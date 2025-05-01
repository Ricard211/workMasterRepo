pipeline {
  agent {
    docker { image 'node:16-alpine' }
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