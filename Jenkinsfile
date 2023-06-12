@Library('hope-jenkins-library')_

import hudson.tasks.test.AbstractTestResultAction

/* Pipeline for testing a PR to hope-src with various updated submodules.
   Stages:
       Setup: Gets which submodules were updated in this PR compared to master and sets initial GitHub status.
       Rebuild tools: Gets tools binaries and rebuilds all the tools (TODO: don't rebuild tools when not needed)
       Set running test status: Updates hope-src and all changed submodules to be pending running tests.
       Run tests: Runs the bare metal and frtos tests on qemu in parallel.
   Post-run actions:
       Updates github status based on success or failure of all previous stages.
 */

String periodic_build = env.BRANCH_NAME == "master" ? "@midnight" : ""
String agent_string = env.BRANCH_NAME == "master" ? "'vcu118 && (ubuntu18.04 || ubuntu22.04)'" : env.BRANCH_NAME ==~ /.*fpga.*/ ? "'vcu118 && (ubuntu18.04 || ubuntu22.04)'" : "(ubuntu18.04 || ubuntu22.04)"

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
    agent { label agent_string }
    triggers { cron(periodic_build) }
    options {
        disableConcurrentBuilds()
        disableResume()
        timeout(time: 4, unit: 'HOURS')
        }
    stages {
        stage('Node Info')
        {
            steps {
                script {
                    echo "Running on node ${env.NODE_NAME} at ${env.WORKSPACE}"
                    sh """
                        hostname
                        nproc
                        free -h
                        df -h .
                        uname -a
                        lsb_release -a || true
                        env
                    """
                }
            }
        }
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
                    shas['src'] = env.GIT_COMMIT
                    changedModules += 'src'
                }

                echo("Getting updated submodules for ${GIT_BRANCH_LOCAL}...")

                setModulesGithubStatus([
                    message: 'Starting hope-src build.',
                    shas: shas,
                    changedModules: changedModules,
                    status: 'PENDING'
                ])

                slackSend color: '#FFFF00', message: "<${env.BUILD_URL}|${env.JOB_NAME}> - #${env.BUILD_NUMBER} - Started."
            }
        }
        stage('Setup for FPGA tests') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch pattern: "pr-*fpga*", comparator: "GLOB"
                    triggeredBy cause: "UserIdCause"
                    triggeredBy 'TimerTrigger'
                }
                expression { return env.NODE_LABELS.contains('vcu118') }
            }
            steps {
                checkoutHopeGfe(branch: "gfe-pipe")
                buildHopeGfe(this)
            }
        }
        stage('Rebuild tools') {
            steps {
                echo "Rebuilding hope-tools with new submodules."
                sh """
                    git checkout ${env.GIT_COMMIT}
                    ./init-submodules.sh -p
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
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh """
                        make -C policies/policy_tests clean
                        export ISP_PREFIX=${ispPrefix}
                        export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}
                        make -C policies/policy_tests build-tests build-policies JOBS=10 CONFIG=bare-hifive32
                        """
                }
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh """
                        export ISP_PREFIX=${ispPrefix}
                        export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}
                        make -C policies/policy_tests run-tests JOBS=10 CONFIG=bare-hifive32
                        """
                }
            }
        }
        stage('Run bare64 tests') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh """
                        export ISP_PREFIX=${ispPrefix}
                        export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}
                        make -C policies/policy_tests build-tests build-policies JOBS=10 CONFIG=bare-hifive64
                        """
                }
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh """
                        export ISP_PREFIX=${ispPrefix}
                        export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}
                        make -C policies/policy_tests run-tests JOBS=10 CONFIG=bare-hifive64
                        """
                }
            }
        }
        stage('Run frtos tests') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh """
                        export ISP_PREFIX=${ispPrefix}
                        export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}
                        make -C policies/policy_tests build-tests build-policies JOBS=10 CONFIG=frtos-hifive32
                        """
                }
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh """
                        export ISP_PREFIX=${ispPrefix}
                        export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}
                        make -C policies/policy_tests run-tests JOBS=10 CONFIG=frtos-hifive32
                        """
                }
            }
        }
        stage('Run frtos64 tests') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh """
                        export ISP_PREFIX=${ispPrefix}
                        export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}
                        make -C policies/policy_tests build-tests build-policies JOBS=10 CONFIG=frtos-hifive64
                        """
                }
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh """
                        export ISP_PREFIX=${ispPrefix}
                        export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}
                        make -C policies/policy_tests run-tests JOBS=10 CONFIG=frtos-hifive64
                        """
                }
            }
        }
        stage('Run debug tests') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh """
                        export ISP_PREFIX=${ispPrefix}
                        export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}
                        export DEBUG=yes
                        export TESTS=hello_works_1,cfi/jump_data_fails_1
                        export POLICIES=cfi,heap
                        make -C policies/policy_tests build-tests build-policies JOBS=10 CONFIG=bare-hifive32
                        make -C policies/policy_tests build-tests build-policies JOBS=10 CONFIG=bare-hifive64
                        make -C policies/policy_tests build-tests build-policies JOBS=10 CONFIG=frtos-hifive32
                        make -C policies/policy_tests build-tests build-policies JOBS=10 CONFIG=frtos-hifive64
                        """
                }
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh """
                        export ISP_PREFIX=${ispPrefix}
                        export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}
                        export DEBUG=yes
                        export TESTS=hello_works_1,cfi/jump_data_fails_1
                        export POLICIES=cfi,heap
                        make -C policies/policy_tests run-tests JOBS=10 CONFIG=bare-hifive32
                        make -C policies/policy_tests run-tests JOBS=10 CONFIG=bare-hifive64
                        make -C policies/policy_tests run-tests JOBS=10 CONFIG=frtos-hifive32
                        make -C policies/policy_tests run-tests JOBS=10 CONFIG=frtos-hifive64
                        """
                }
            }
        }
        stage('Run FPGA tests') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch pattern: "pr-*fpga*", comparator: "GLOB"
                    triggeredBy cause: "UserIdCause"
                    triggeredBy 'TimerTrigger'
                }
                expression { return env.NODE_LABELS.contains('vcu118') }
            }
            steps {
                echo "getting lock to run tests"
                lock(resource:"${env.NODE_NAME}-VCU118", variable: "LOCKED_RESOURCE") {
                    echo "Running tests"
                    sh """
                            export ISP_PREFIX=${ispPrefix}
                            export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}:/opt/Xilinx/Vivado/2019.2/bin
                            make -C policies/policy_tests clean-tests clean-policies
                        """
                    catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                        sh """
                            export ISP_PREFIX=${ispPrefix}
                            export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}:/opt/Xilinx/Vivado/2019.2/bin
                            make -C policies/policy_tests run-tests JOBS=1 TESTS=hello_works_1,cfi/jump_data_fails_1 CONFIG=bare-ssith-p1
                            """
                    }
                    sh " killall -9 hw_server || true "
                    catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                        sh """
                            export ISP_PREFIX=${ispPrefix}
                            export PATH=${ispPrefix}/bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}:/opt/Xilinx/Vivado/2019.2/bin
                            export BITSTREAM=${ispPrefix}/vcu118/bitstreams/soc_chisel_pipe_p2.bit
                            make -C policies/policy_tests run-tests JOBS=1 TESTS=hello_works_1,cfi/jump_data_fails_1 CONFIG=bare-ssith-p2
                            """
                    }
                    sh " killall -9 hw_server || true "
                    catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                        sh """
                            export ISP_PREFIX=${ispPrefix}
                            export PATH=${ispPrefix}bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}:/opt/Xilinx/Vivado/2019.2/bin
                            make -C policies/policy_tests run-tests JOBS=1 TESTS=hello_works_1,cfi/jump_data_fails_1  GPOLICIES= POLICIES=rwx,none,stack,heap,cfi CONFIG=frtos-vcu118
                            """
                    }
                    sh " killall -9 hw_server || true "
                    catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                        sh """
                            export ISP_PREFIX=${ispPrefix}
                            export PATH=${ispPrefix}/bin:${env.JENKINS_HOME}/.local/bin:${env.PATH}:/opt/Xilinx/Vivado/2019.2/bin
                            export BITSTREAM=${ispPrefix}/vcu118/bitstreams/soc_chisel_pipe_p2.bit
                            make -C policies/policy_tests run-tests JOBS=1 TESTS=hello_works_1  GPOLICIES= POLICIES=rwx COMPOSITE=none CONFIG=frtos64-vcu118
                            """
                    }
                    sh " killall -9 hw_server || true "
                }
            }
        }
    }
    post {
        always {
            junit 'policies/policy_tests/*_report.xml'
        }
        success {
            echo "Successfully ran all tests!"
            //deleteDir()
            setModulesGithubStatus([
                message: "All tests passed.",
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
            dir("${env.ISP_PREFIX}/policies") {
                deleteDir()
            }

            slackSend color: '#00FF00', message: "<${env.BUILD_URL}|${env.JOB_NAME}> - #${env.BUILD_NUMBER} - Succeeded."
        }
        unstable {
            echo "Some tests failed!"
            script {
                AbstractTestResultAction tra =  currentBuild.rawBuild.getAction(AbstractTestResultAction.class)
                if (tra != null) {
                    failed = tra.failCount
                    total = tra.totalCount - tra.skipCount
                }
            }
            setModulesGithubStatus([
                message: "${failed} of ${total} tests failed.",
                shas: shas,
                changedModules: changedModules,
                status: 'FAILURE'
            ])
            slackSend color: '#F09E27', message: "<${env.BUILD_URL}|${env.JOB_NAME}> - #${env.BUILD_NUMBER}\n" + listFailedTests()

        }
        failure {
            setModulesGithubStatus([
                message: "Something unexpected failed.",
                shas: shas,
                changedModules: changedModules,
                status: 'FAILURE'
            ])

            slackSend color: '#FF0000', message: "<${env.BUILD_URL}|${env.JOB_NAME}> - #${env.BUILD_NUMBER} - Failed."
        }
    }
}
