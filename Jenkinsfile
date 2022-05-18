pipeline {
    agent { label 'node1' }

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