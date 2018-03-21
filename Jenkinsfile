pipeline {
     environment {
          MAIL = "matias.gonzalez@grupoesfera.com.ar"
          SLACK_CHANNEL = "demo-failed-jobs"
          API_NAME = "demo-api"

    }
agent any

    stages {
        stage('Build + Unit Test') {
            agent {
                 docker {
                     image 'gradle:4.6.0-jdk8-alpine'
                     args '-v $HOME/.gradle:/home/gradle/.gradle'
                 }
             }

             steps {
                sh 'gradle test'
                junit 'build/test-results/test/*.xml'
                
            }
        }
        stage('Create docker image'){

            agent {
                   docker {
                       image 'gradle:4.6.0-jdk8-alpine'
                       args '-v $HOME/.gradle:/home/gradle/.gradle'
                   }
               }
            steps {
                 script{
                     env.VERSION = env.BRANCH_NAME == "master" ? "build-${env.BUILD_NUMBER}" : "latest"
                     sh "gradle -DappVersion=${env.VERSION} -DapiName=${env.API_NAME} buildImage -x test"
                }
            }
        }
        stage('Deploy CI'){

            steps {
                sh "sh deploy-ci.sh ${env.API_NAME} ${env.VERSION}"
            }
        }
          stage('Integration Test'){

            steps {
                //polemico necesito solución alternativa
                sh 'docker run -v /var/lib/docker/volumes/jenkins-data/_data/workspace/demo-3_develop-PCXMIVKOQCVF5ZGT4TOCQXASPPPMZQZWMEO2JUUU4OGUCK6ZVN4Q/postman-collection:/etc/newman -t postman/newman_ubuntu1404     run "demo-api.json.postman_collection"  --disable-unicode    --environment="test.json.postman_environment" --reporters="html,cli" --reporter-html-export="newman-results.html"'

                publishHTML (target: [
                             allowMissing: false,
                             alwaysLinkToLastBuild: false,
                             keepAll: true,
                             reportDir: 'postman-collection/newman',
                             reportFiles: 'newman-run-report*.html',
                             reportName: "Integration test result"
                           ])
            }
        }
       stage('Merge to Staging'){
            when { branch 'develop' }
             agent {
                    docker {
                        image 'alpine/git'
                        args '-v $HOME:/home/build'
                    }
                }
            steps {

               script {
                   result = null
                   try {
                    timeout(time:60, unit:'SECONDS') {
                        input message: 'Do you want to merge?',
                              parameters: [[$class: 'BooleanParameterDefinition',
                                            defaultValue: false,
                                            description: '',
                                            name: 'Release']]
                    }

                    sh "git tag  build-${env.BUILD_NUMBER}"

                } catch (err) {
                    result = false
                    println "Timeout for merge   reached"
                    }
               }
          }
        }

    }
    post{
        failure {
               println "enviando mensaje al canal de slack $SLACK_CHANNEL"
               slackSend ( channel:SLACK_CHANNEL,
                            color: '#ff0000',
                            message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")

                emailext (
                  subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                  body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                    <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""",
                  to: MAIL
             )
         }
    }
}