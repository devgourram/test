pipeline {
    agent { label 'php' }

    options {
        // Disallow concurrent executions of the Pipeline because of database
        // Use $env.BRANCH_NAME or $env.BUILD_NUMBER
        disableConcurrentBuilds()
    }

    stages {
        stage('Composer') {
            steps {
                slackSend "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (<${env.BUILD_URL}|Open>)"
                // phing installation, ignoring composer scripts
                sh 'composer -v install --no-interaction --no-scripts'
            }
        }
        stage('Test') {
            steps {
                sh './bin/phing'
            }
        }
        stage('Reports') {
            steps {
                checkstyle canComputeNew: false, defaultEncoding: '', healthy: '', pattern: '', unHealthy: ''
                dry canComputeNew: false, defaultEncoding: '', healthy: '', pattern: '', unHealthy: ''
                publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: './docs/', reportFiles: 'index.html', reportName: 'PHP Documentation', reportTitles: ''])
            }
        }
    }

    post {
        success {
            slackSend (color: '#3CB371', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (<${env.BUILD_URL}|Open>)")
        }
        failure {
            slackSend (color: '#B22222', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (<${env.BUILD_URL}|Open>)")
            emailext body: """${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - FAILURE:
Check console output at ${env.BUILD_URL} to view the results.""", recipientProviders: [culprits()], subject: "[CI]${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - FAILURE!"
        }
        unstable {
            slackSend (color: '#FFA500', message: "UNSTABLE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (<${env.BUILD_URL}|Open>)")
        }
        always {
            script {
                if (fileExists('./bin/phing')) {
                    echo 'Cleaning'
                    sh './bin/phing doctrine-clean'
                }
            }
        }
    }
}