pipeline {
  agent any
  stages {
    stage('Version Check') {
      steps {
        sh '''#check a file to see if the version has incremented
#if so then do a build - if not then retire'''
      }
    }
    stage('Kernel Setup') {
      steps {
        sh '''#un-tar the kernel and
#install the headers'''
      }
    }
  }
}