pipeline {
  agent {
    docker { image 'node:16-alpine' }
  }
  stages {
    stage('Test') {
      steps {
        sh 'node --version'
        sh 'ls -l'
        sh '.process.sh'
      }
    }
  }
}