node {
    tools {"org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform-0.11.10"}

    environment {
        TF_HOME = tool('terraform-0.11.10')
        TF_IN_AUTOMATION = "true"
        PATH = "$TF_HOME:$PATH"
        ACCESS_KEY = credentials('jenkins-aws-secret-key-id')
        SECRET_KEY = credentials('jenkins-aws-secret-access-key')
    }

    echo "workspace directory is ${workspace}"

    stage('checkout') {
        checkout scm
    }

    stage('check java') {
        sh "java -version"
    }

    script {
      version = sh (
               script: "./gradlew properties -q | grep \"^version:\" | awk '{print \$2}'",
                        returnStdout: true
              ).trim()
              sh "echo Building project in version: $version"
    }

    stage('clean') {
        sh "chmod +x gradlew"
        sh "./gradlew clean --no-daemon"
    }

    stage('build') {
        sh "./gradlew npm_install -Pprod -PnodeInstall --no-daemon"
    }


    stage('backend tests') {
        try {
            sh "./gradlew test integrationTest -Pprod -PnodeInstall --no-daemon"
        } catch(err) {
            throw err
        } finally {
            junit '**/build/**/TEST-*.xml' } } 

    stage('frontend tests') { 
       try {
            sh "./gradlew npm_run_test -Pprod -PnodeInstall --no-daemon"
        } catch(err) {
            throw err
        } finally {
            junit '**/build/test-results/TESTS-*.xml'
        }
    }
    
    stage('packaging') {
      sh "./gradlew bootJar -x test -Pprod -PnodeInstall --no-daemon"
           archiveArtifacts artifacts: '**/build/libs/*.jar', fingerprint: true
    }

   stage ('Publish') {
       nexusPublisher nexusInstanceId: 'stsnexus', nexusRepositoryId: 'maven-releases', packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: "${workspace}/build/libs/devopsdemo-${version}.jar"]], mavenCoordinate: [artifactId: 'devops-demo', groupId: 'com.simpletechnologysolutions', packaging: 'jar', version: "${version}" ]]]
   }

    stage('terraform init') {
        dir('./terraform/prod'){
            sh "echo 'Initializing Terraform'"
            sh "terraform init -input=false"
        }
    }

    stage('terraform plan'){
        dir('./terraform/prod'){
            sh "echo 'Planning Terraform Build'"
            sh "terraform plan -var 'access_key=$ACCESS_KEY' -var 'secret_key=$SECRET_KEY'"
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