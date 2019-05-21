

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

// Testing deliverying artifact to Nexus server
    stage('Deliver') {
       sh 'ssh -o StrictHostKeyChecking=no  -i /var/lib/jenkins/.ssh/sts-ILab-20181012.pem ec2-user@ip-172-31-39-105.ec2.internal "/sbin/service jhipster stop"'
       sh 'scp -v -o StrictHostKeyChecking=no  -i /var/lib/jenkins/.ssh/sts-ILab-20181012.pem /var/lib/jenkins/jobs/devops-demo-jhipster/lastSuccessful/archive/build/libs/devopsdemo-0.0.1-SNAPSHOT.jar  ec2-user@ip-172-31-39-105.ec2.internal:/home/ec2-user/lib'
       sh 'ssh -o StrictHostKeyChecking=no  -i /var/lib/jenkins/.ssh/sts-ILab-20181012.pem ec2-user@ip-172-31-39-105.ec2.internal "/sbin/service jhipster start"'
    }

   stage ('Publish') {
     // nexusPublisher nexusInstanceId: 'stsnexus', nexusRepositoryId: 'maven-snapshots', packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: '/var/lib/jenkins/jobs/devops-demo-jhipster/lastSuccessful/archive/build/libs/devopsdemo-0.0.1-SNAPSHOT.jar']], mavenCoordinate: [artifactId: 'devopsdemo-0.0.1-SNAPSHOT.jar', groupId: 'com.simpletechnologysolutions.main', packaging: 'jar', version: '1.0.0']]]

     // nexusPublisher nexusInstanceId: 'stsnexus', nexusRepositoryId: 'maven-snapshots', packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: '/var/lib/jenkins/jobs/devops-demo-jhipster/lastSuccessful/archive/build/libs/devopsdemo-0.0.1-SNAPSHOT.jar']], mavenCoordinate: [artifactId: 'devops-demo', groupId: 'com.simpletechnologysolutions', packaging: 'jar', version: '1.0.0-SNAPSHOT']]]
     nexusPublisher nexusInstanceId: 'stsnexus', nexusRepositoryId: 'maven-releases', packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: '/var/lib/jenkins/jobs/devops-demo-jhipster/lastSuccessful/archive/build/libs/devopsdemo-0.0.1-SNAPSHOT.jar']], mavenCoordinate: [artifactId: 'devops-demo', groupId: 'com.simpletechnologysolutions', packaging: 'jar', version: '1.0.0-SNAPSHOT']]]
   }
}
