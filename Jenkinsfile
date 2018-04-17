pipeline {
  agent any
  stages {
    stage('Version Check') {
      steps {
        sh '''#check a file to see if the version has incremented
#if so then do a build - if not then retire'''
      }
    }
    stage('Test') {
      steps {
        sh '#this is a test'
      }
    }
  }
}