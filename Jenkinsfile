node {
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
}
