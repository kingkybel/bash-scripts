#!/usr/bin/bash

[[ "${0}" != "${BASH_SOURCE[0]}" ]] && THIS_FILE="${BASH_SOURCE[0]}" || THIS_FILE="${0}"
THIS_DIR=$(realpath "$(dirname ${THIS_FILE})")
THIS_SCRIPT=$(basename "${THIS_FILE}")

ERS='\033[0m'    # reset
EHC='\033[1m'    # hicolor
EFRED='\033[31m' # foreground red
EFGRN='\033[32m' # foreground green
EFYEL='\033[33m' # foreground yellow
EFCYN='\033[36m' # foreground cyan
EFWHT='\033[37m' # foreground white

FINISH=N
DRY_RUN="echo -e "
CURRENT_DIR=$(pwd)
REPO_DIR=${CURRENT_DIR}
DEFAULT_BASE_BRANCH=feature
BASE_BRANCH=${DEFAULT_BASE_BRANCH}
SUGGESTED_BASE_BRANCHES="feature, fix, prod-hotfix"
JIRA_TITLE_DEFAULT="SE 123 Add XYZ-feature"
JIRA_TITLE="${JIRA_TITLE_DEFAULT}"
BRANCH_NAME_DEFAULT="${BASE_BRANCH}/${JIRA_TITLE_DEFAULT// /-}"
BRANCH_NAME="${BASE_BRANCH}/${JIRA_TITLE// /-}"

function printUsage() {
    printf "${EHC}USAGE:${ERS}\n%s -j <${EFGRN}'JIRA-number and header'${ERS}> [-r <${EFGRN}repo-directory${ERS}>] [-b <${EFGRN}base-branch${ERS}>] [-e]\n\
     ${EFYEL}-j${ERS} | ${EFYEL}--jira-title${ERS}:  JIRA-number and the header of the task (enclose in quotes!)\n\
     ${EFYEL}-r${ERS} | ${EFYEL}--repo-dir${ERS}:    directory of the repo, defaults to '${REPO_DIR}'\n\
     ${EFYEL}-b${ERS} | ${EFYEL}--base-branch${ERS}: based on branch, defaults to '${BASE_BRANCH}' (suggested: ${SUGGESTED_BASE_BRANCHES})\n\
     ${EFYEL}-e${ERS} | ${EFYEL}--execute${ERS}:     execute commands, by default do a dry-run: just show commands that will be executed\n\n\
          e.g.: taskBranch --jira-title ${EFGRN}'${JIRA_TITLE_DEFAULT}'${ERS} --repo-dir ${EFGRN}~/Repos/myRepo${ERS} --base-branch ${EFGRN}'${DEFAULT_BASE_BRANCH}'${ERS}\n\n\
          creates ${EFRED}local${ERS}:\t${EFGRN}${BRANCH_NAME_DEFAULT}${ERS} as branch of\n\
          ${EFRED}remote${ERS}:\t\torigin/${EFCYN}${DEFAULT_BASE_BRANCH}${ERS} and\n\
          tracking ${EFRED}upstream${ERS}:\torigin/${EFGRN}${BRANCH_NAME}${ERS}\n\n\
      " "${THIS_SCRIPT}"
}

OPTIONS=$(getopt -o j:r:b:eh --long jira-title:,repo-dir:,base-branch,execute,help -- "$@")
if [ $? != 0 ]; then
    echo "Terminating..." >&2
    exit 1
fi


# Note the quotes around '$OPTIONS': they are essential!
eval set -- "$OPTIONS"

while true; do
    case "$1" in
    -j | --jira-title)
        JIRA_TITLE=$2
        shift
        ;;
    -b | --base-branch)
        BASE_BRANCH=$2
        shift
        ;;
    -r | --repo-dir)
        REPO_DIR=$2
        shift
        ;;
    -e | --execute)
        DRY_RUN=""
        ;;
    -h | --help)
        FINISH=y
        printUsage
        ;;
    --)
         break
        ;;
    *) break ;;
    esac
    shift
done

if [ "$FINISH" = "N" ]; then
    echo -e "${EFGRN} ### change directory to ${REPO_DIR}...${EFWHT}"
    BRANCH_NAME="${JIRA_TITLE// /-}"
    ${DRY_RUN} cd "${REPO_DIR}"

    [ $(git branch --list "${BASE_BRANCH}") ] || {
        printf "\n${EFRED} Base branch '%s' does not exist. Terminating...${ERS}\n" "${BASE_BRANCH}"
        ${DRY_RUN} exit 0
    }
    # first checkout the origin and get all the latest
    echo -e "${EFGRN} ### checkout base branch '${BASE_BRANCH}'...${EFWHT}"
    ${DRY_RUN} git checkout "${BASE_BRANCH}" || {
        printf "\n${EFRED} Cannot checkout base branch '%s'. Terminating...${ERS}\n" "${BASE_BRANCH}"
        ${DRY_RUN} exit 0
    }
    echo -e "${EFGRN} ### update base branch '${BASE_BRANCH}'...${EFWHT}"
    ${DRY_RUN} git pull
    # create the branch and push to upstream
    echo -e "${EFGRN} ### create task-branch branch '${BRANCH_NAME}'...${EFWHT}"
    ${DRY_RUN} git checkout -b "${BRANCH_NAME}"
    echo -e "${EFGRN} ### push to remote '${BRANCH_NAME}'...${EFWHT}"
    ${DRY_RUN} git push origin HEAD
    echo -e "${EFGRN} ### change directory to ${CURRENT_DIR}...${EFWHT}"
    ${DRY_RUN} cd "${CURRENT_DIR}"

    [ "${DRY_RUN}" == "" ] || printf "\n${EFYEL}WARNING: this was a dry-run. Use parameter -e | --execute to execute the commands.${ERS}\n\n"
fi
