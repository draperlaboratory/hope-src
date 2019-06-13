@Library('hope-jenkins-library')_

/* Pipeline for testing a PR to hope-src with various updated submodules.
   Stages:
       Setup: Gets which submodules were updated in this PR compared to master and sets initial GitHub status.
       Rebuild tools: Gets tools binaries and rebuilds all the tools (TODO: don't rebuild tools when not needed)
       Set running test status: Updates hope-src and all changed submodules to be pending running tests.
       Run tests: Runs the bare metal and frtos tests on qemu in parallel.
   Post-run actions:
       Updates github status based on success or failure of all previous stages.
 */

def getGitModuleSha(String module) {
    return sh(script: """cd ${env.WORKSPACE}
                         git submodule update --init ${module}
                         cd ${env.WORKSPACE}/${module}
                         git rev-parse HEAD""",
              returnStdout: true).trim()
}

def getUpdatedModuleShas(changedModules) {
    def shas = [:]
    def submoduleList = sh(script: 'git submodule', returnStdout: true).trim()
    submoduleList.split('\n').each { line ->
        def lineSplit = line.split()
        def sha = lineSplit[0]
        def module = lineSplit[1]
        if (changedModules.contains(module)) {
            shas[module] = sha
        }
    }
    return shas
}

def changedModules
def shas
def ispPrefix
pipeline {
    agent any
    stages {
        stage('Setup') {
            steps {
                script {
                    changedModules = getChangedSubmodules()
                    shas = getUpdatedModuleShas(changedModules)
                    ispPrefix = "${env.WORKSPACE}/isp-bin/"
                    echo "In top changedModules = ${changedModules}"
                    GIT_BRANCH_LOCAL = sh (
                        script: "echo ${env.GIT_BRANCH} | sed -e 's|origin/||g'",
                        returnStdout: true
                    ).trim()
                }

                echo("Getting updated submodules for ${GIT_BRANCH_LOCAL}...")
                checkoutHopeSrc([
                    branch: GIT_BRANCH_LOCAL
                ])

                setModulesGithubStatus([
                    message: 'Starting hope-src build.',
                    shas: shas,
                    changedModules: changedModules,
                    status: 'PENDING'
                ])

                slackSend color: '#FFFF00', message: "${env.JOB_NAME} - ${env.BUILD_NUMBER} Started at ${env.BUILD_URL}."
            }
        }
        stage('Rebuild tools') {
            steps {
                echo "Rebuilding hope-tools with new submodules."
                copyArtifacts(filter: 'tools-bin.tar.bz2', fingerprintArtifacts: true, projectName: 'hope-base-tools')
                // copyArtifacts(filter: 'tools-built-src.tar.bz2', fingerprintArtifacts: true, projectName: 'hope-base-tools')
                sh 'tar xJf tools-bin.tar.bz2'
                // sh 'tar xJf tools-built-src.tar.bz2 -C hope-src-full'
                sh """
                    git checkout ${env.GIT_COMMIT}
                    git submodule update --init --recursive
                """
                buildHope(this)
            }
        }
        stage('Set running test status') {
            steps {
                setModulesGithubStatus([
                    message: "Running tests for hope-src.",
                    shas: shas,
                    changedModules: changedModules,
                    status: 'PENDING'
                ])
            }
        }
        stage('Run bare tests') {
            steps {
                sh """
                            make -C policies/policy_tests clean
                            export ISP_PREFIX=${ispPrefix}
                            export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}
                            make test-bare JOBS=auto
                        """
            }
        }
        stage('Run frtos tests') {
            steps {
                sh """
                            make -C policies/policy_tests clean
                            export ISP_PREFIX=${ispPrefix}
                            export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}
                            make test-frtos JOBS=auto
                        """
            }
        }
    }
    post {
        success {
            echo "Successfully ran all tests!"
            //deleteDir()
            setModulesGithubStatus([
                message: "All frtos and bare tests passed.",
                shas: shas,
                changedModules: changedModules,
                status: 'SUCCESS'
            ])
            dir('policies/policy_tests/build') {
                deleteDir()
            }
            dir('policies/policy_tests/output') {
                deleteDir()
            }
            sh "make -C policies/policy_tests clean"
            dir("${env.ISP_PREFIX}/kernels") {
                deleteDir()
            }

            slackSend color: '#00FF00', message: "${env.JOB_NAME} - ${env.BUILD_NUMBER} Succeeded at ${env.BUILD_URL}."
        }
        failure {
            echo "Some tests failed!"
            setModulesGithubStatus([
                message: "Some frtos and bare tests failed.",
                shas: shas,
                changedModules: changedModules,
                status: 'FAILURE'
            ])

            slackSend color: '#FF0000', message: "${env.JOB_NAME} - ${env.BUILD_NUMBER} Failed at ${env.BUILD_URL}."
        }
    }
}
