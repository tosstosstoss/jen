pipeline {
    agent { label 'puscha' }

    stages {
        stage('Prepare') {
            steps {
                echo 'This is Prepare stage'
                sh 'pwd'
                sh 'ls -la'
            }
        }

        stage('Execution') {
            steps {
                echo 'This is Execution stage'
            }
        }

        stage('Report') {
            steps {
                echo 'This is Report stage'
            }
        }
    }

}