#!/usr/bin/env groovy

node {
    stage('checkout') {
        checkout scm
    }

    stage('check java') {
        sh "java -version"
    }

    stage('clean') {
        sh "chmod +x gradlew"
        sh "./gradlew clean --no-daemon"
    }

    stage('npm install') {
        sh "./gradlew npm_install -PnodeInstall --no-daemon"
    }

    stage('backend tests') {
        try {
            sh "./gradlew test integrationTest -PnodeInstall --no-daemon"
        } catch(err) {
            throw err
        } finally {
            junit '**/build/**/TEST-*.xml'
        }
    }

    stage('frontend tests') {
        try {
            sh "./gradlew npm_run_test -PnodeInstall --no-daemon"
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

    stage('Deliver') {
       sh 'ssh -o StrictHostKeyChecking=no  -i /var/lib/jenkins/.ssh/sts-ILab-20181012.pem ec2-user@ip-172-31-39-105.ec2.internal "/sbin/service jhipster stop"'
       sh 'scp -v -o StrictHostKeyChecking=no  -i /var/lib/jenkins/.ssh/sts-ILab-20181012.pem /var/lib/jenkins/jobs/devops-demo-jhipster/lastSuccessful/archive/build/libs/devopsdemo-0.0.1-SNAPSHOT.jar  ec2-user@ip-172-31-39-105.ec2.internal:/home/ec2-user/lib'
       sh 'ssh -o StrictHostKeyChecking=no  -i /var/lib/jenkins/.ssh/sts-ILab-20181012.pem ec2-user@ip-172-31-39-105.ec2.internal "/sbin/service jhipster start"'
    }

   stage ('Publish') {
	nexusArtifactUploader artifacts: [
	   [artifactId: 'nexus-artifact-uploader', classifier: 'debug', file: '/var/lib/jenkins/jobs/devops-demo-jhipster/lastSuccessful/archive/build/libs/devopsdemo-0.0.1-SNAPSHOT.jar', type: 'jar'], 
	], 
	credentialsId: '06d02dac-a365-47fc-ac92-c6a81bd86d3c', 
	groupId: 'sp.sd', 
	nexusUrl: 'localhost:8081/nexus', 
	nexusVersion: 'nexus2', 
	protocol: 'http', 
	repository: 'NexusArtifactUploader', 
	version: '2.4'
}

}
