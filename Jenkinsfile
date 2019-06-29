pipeline {
    agent any 

    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform-0.11.10"
    }

    environment {
        TF_HOME = tool('terraform-0.11.10')
        TF_IN_AUTOMATION = "true"
        PATH = "$TF_HOME:$PATH"
        ACCESS_KEY = credentials('jenkins-aws-secret-key-id')
        SECRET_KEY = credentials('jenkins-aws-secret-access-key')
    }

    stages{
          stage('checkout') {
              steps {
                  checkout scm
                  echo "workspace directory is ${workspace}"
              }   
          }

          stage('terraform destroy') {
            steps {
                dir('./terraform/prod'){
                    sh "terraform --version"
                    sh "echo 'Destroying old Infrastructure'"
                    sh "terraform destroy --auto-approve"
                }
            }
          }

          stage('check java') {
              steps {
                  sh "java -version"
              }      
          }

          stage('get project version') {
              steps {
                  script {
                      version = sh (
                              script: "./gradlew properties -q | grep \"^version:\" | awk '{print \$2}'",
                                          returnStdout: true
                              ).trim()
                              sh "echo Building project in version: $version"
                  }
              }
          }
        
          stage('clean') {
              steps {
                  sh "chmod +x gradlew"
                  sh "./gradlew clean --no-daemon"
              }
          }

          stage('build') {
              steps {
                  sh "./gradlew npm_install -Pprod -PnodeInstall --no-daemon"
              }
          }

          stage('quality analysis') {
              steps {
                  withSonarQubeEnv('sonarqube') {
                      sh "./gradlew sonarqube --no-daemon -PnodeInstall -Pprod"
                  }
              }
          }

          stage('backend tests') {
              steps {
                  script {
                      try {
                          sh "./gradlew test integrationTest -Pprod -PnodeInstall --no-daemon"
                      } catch(err) {
                          throw err
                      } finally {
                          junit '**/build/**/TEST-*.xml' } 
                  }
              } 
          }
            

          stage('frontend tests') {
              steps {
                  script {
                      try {
                          sh "./gradlew npm_run_test -Pprod -PnodeInstall --no-daemon"
                      } catch(err) {
                          throw err
                      } finally {
                          junit '**/build/test-results/TESTS-*.xml' }
                  }
              } 
          }

          stage('packaging') {
              steps {
                  sh "./gradlew bootJar -x test -Pprod -PnodeInstall --no-daemon"
                  archiveArtifacts artifacts: '**/build/libs/*.jar', fingerprint: true
              }
          }

          stage ('Publish') {
              steps {
                  nexusPublisher nexusInstanceId: 'stsnexus', nexusRepositoryId: 'maven-releases', packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: "${workspace}/build/libs/devopsdemo-${version}.jar"]], mavenCoordinate: [artifactId: 'devops-demo', groupId: 'com.simpletechnologysolutions', packaging: 'jar', version: "${version}" ]]]
              }
          }

        stage('terraform init') {
            steps {
                dir('./terraform/prod'){
                    sh "terraform --version"
                    sh "echo 'Initializing Terraform'"
                    sh "terraform init -input=false"
                }
            }
        }

        stage('terraform plan'){
            steps {
                dir('./terraform/prod'){
                    sh "echo 'Planning Terraform Build'"
                    sh "terraform plan"
                }
            }
        }

         stage('terraform apply'){
             steps {
                 script{
                     def apply = false
                     try {
                         input message: 'Can you please confirm the apply', ok: 'Ready to Apply the Config'
                         apply = true
                     } catch (err) {
                         apply = false
                             currentBuild.result = 'UNSTABLE'
                     }
                     if(apply){
                         dir('./terraform/prod'){
                             sh "echo 'Applying Terraform'"
                             sh 'terraform apply --auto-approve'
                         }
                     }
                 }
             }
         }
    }   
}
