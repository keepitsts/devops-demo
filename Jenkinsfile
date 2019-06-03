node {
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

    stage('npm install') {
        sh "./gradlew npm_install -Pprod -PnodeInstall --no-daemon"
    }

/***  SKIP TESTING FOR NOW  */
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
//    }

/**/
    stage('packaging') {
        sh "./gradlew bootJar -x test -Pprod -PnodeInstall --no-daemon"
        archiveArtifacts artifacts: '**/build/libs/*.jar', fingerprint: true
    }

// Testing deliverying artifact to Nexus server
// Having trouble find jar file.  If we get it in Nexus, we don't need this step
//    stage('Deliver') {
//       sh 'ssh -o StrictHostKeyChecking=no  -i /var/lib/jenkins/.ssh/sts-ILab-20181012.pem ec2-user@ip-172-31-39-105.ec2.internal "/sbin/service jhipster stop"'
//       sh 'scp -v -o StrictHostKeyChecking=no  -i /var/lib/jenkins/.ssh/sts-ILab-20181012.pem /var/lib/jenkins/jobs/devops-demo-jhipster/lastSuccessful/archive/build/libs/devopsdemo-1.0.0.jar  ec2-user@ip-172-31-39-105.ec2.internal:/home/ec2-user/lib' 
//       sh 'ssh -o StrictHostKeyChecking=no  -i /var/lib/jenkins/.ssh/sts-ILab-20181012.pem ec2-user@ip-172-31-39-105.ec2.internal "/sbin/service jhipster start"'
//    }
//

   stage ('Publish') {
       nexusPublisher nexusInstanceId: 'stsnexus', nexusRepositoryId: 'maven-releases', packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: "/var/lib/jenkins/workspace/devops-demo-jhipster/build/libs/devopsdemo-${version}.jar"]], mavenCoordinate: [artifactId: 'devops-demo', groupId: 'com.simpletechnologysolutions', packaging: 'jar', version: "${version}" ]]]
   }
}
