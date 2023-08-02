#!/bin/bash
[[ "${0}" != "${BASH_SOURCE[0]}" ]] && THIS_FILE="${BASH_SOURCE[0]}" || THIS_FILE="${0}"
THIS_DIR=$(realpath "$(dirname ${THIS_FILE})")

CURRENT_OS=$(uname)

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

CURRENT_OS=`uname`
echo "OS is '${CURRENT_OS}'"

IS_LINUX=No
if [[ ${CURRENT_OS} =~ "Linux" ]]; then
  IS_LINUX=Yes
fi

IS_GITBASH=No
if [[ ${CURRENT_OS} =~ "MINGW64_NT" ]]; then
  IS_GITBASH=Yes
fi

alias l="ls -Fax"
alias ll="ls -Fasl"
alias v=vim
alias m=less
alias cls=clear
alias findExe="find . -perm -u+x -type f "
alias h=history
alias showBranch="git branch -vv"
alias fetchAll="git fetch --all"
alias myps="ps -eaf | $GREP `id | cut -f2 -d'(' | cut -f1 -d')'`"
alias cd..="cd .."
alias cd-="cd -"
alias hexdump="od -x -A x"
alias mystat="prstat -s rss -u `whoami`"
export GREP_COLORS="ms=01;31:mc=01;31:sl=:cx=:fn=36:ln=32:bn=32:se=36"
export GREP_OPTIONS=--color

# ANSI color codes
RS="\[\033[0m\]"    # reset
HC="\[\033[1m\]"    # hicolor
UL="\[\033[4m\]"    # underline
INV="\[\033[7m\]"   # inverse background and foreground
FBLK="\[\033[30m\]" # foreground black
FRED="\[\033[31m\]" # foreground red
FGRN="\[\033[32m\]" # foreground green
FYEL="\[\033[33m\]" # foreground yellow
FBLE="\[\033[34m\]" # foreground blue
FMAG="\[\033[35m\]" # foreground magenta
FCYN="\[\033[36m\]" # foreground cyan
FWHT="\[\033[37m\]" # foreground white
BBLK="\[\033[40m\]" # background blackG
BRED="\[\033[41m\]" # background red
BGRN="\[\033[42m\]" # background green
BYEL="\[\033[43m\]" # background yellow
BBLE="\[\033[44m\]" # background blue
BMAG="\[\033[45m\]" # background magenta
BCYN="\[\033[46m\]" # background cyan
BWHT="\[\033[47m\]" # background white

ERS='\033[0m'		# reset
EHC='033[1m'		# hicolor
EUL='\033[4m'		# underline
EINV='\033[7m'		# inverse background and foreground
EFBLK='\033[30m'	# foreground black
EFRED='\033[31m'	# foreground red
EFGRN='\033[32m'	# foreground green
EFYEL='\033[33m'	# foreground yellow
EFBLE='\033[34m'	# foreground blue
EFMAG='\033[35m'	# foreground magenta
EFCYN='\033[36m'	# foreground cyan
EFWHT='\033[37m'	# foreground white
EBBLK='\033[40m'	# background blackG
EBRED='\033[41m'	# background red
EBGRN='\033[42m'	# background green
EBYEL='\033[43m'	# background yellow
EBBLE='\033[44m'	# background blue
EBMAG='\033[45m'	# background magenta
EBCYN='\033[46m'	# background cyan
EBWHT='\033[47m'	# background white

export MY_HOST=$(hostname)

function prompt() {
	PS1="\u@\h [\t]> "

	if [ "${IS_LINUX}X" = "YesX" ]; then
		if [ "$(whoami)X" = "rootX" ]; then
			PS1="\$(date +%H:%M:%S) ${BRED}${FYEL}\u@\h ${FRED}[${FCYN}\w ${FRED}]>${RS} "
		else
			PS1="\$(date +%H:%M:%S) ${FBLE}\u@\h ${FRED}[${FCYN}\w ${FRED}]>${RS} "
		fi
		PS2='continue-> '
		PS4='$0.$LINENO+ '
	fi

	if [ "${IS_GITBASH}X" = "YesX" ]; then
		PS1="${HC}${FYEL}[${FMAG}\A${FRED}$(__git_ps1) ${FCYN}${debian_chroot:+($debian_chroot)}\u${FYEL}: ${FBLE}\w ${FYEL}> ${RS}"
		PS2="${HC}${FYEL}&gt; ${RS}"
	fi
}
prompt

stty erase ^H
stty -istrip


function addPath
{
	PATHS=`echo ${PATH} | tr ':' '\ '`
	DONT_ADD=FALSE
	for i in ${PATHS} nomore ; do
		if [ ${i} = nomore ]; then
			break;
		fi;
		if [ "${i}" = "${1}" ]; then
			DONT_ADD=TRUE
		fi;
	done
	if [ "${DONT_ADD}" = "FALSE" ] ; then
		export PATH="${PATH}:${1}"
	fi;
}

function addLDPath
{
	PATHS=`echo ${LD_LIBRARY_PATH} | tr [:] [\ ]`
	DONT_ADD=FALSE
	for i in ${PATHS} nomore ; do
		if [ ${i} = nomore ]; then
			break;
		fi;
		if [ "${i}" = "${1}" ]; then
			DONT_ADD=TRUE
		fi;
	done
	if [ "${DONT_ADD}" = "FALSE" ] ; then
		export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${1}"

	fi;
}


function top10
{
	OPTIND=1
	USAGE1="totalSize [-p <path>] [-h]"
	CHECK_PATH=$1
	DO_EXECUTE=1
	while getopts "p:h" OPTION; do
            case ${OPTION} in
                p) CHECK_PATH=${OPTARG} ;;
                h) echo "${USAGE1}" 
		   DO_EXECUTE=0 ;;
                *) echo "${USAGE1}" 
		   DO_EXECUTE=0 ;;
            esac
	done
	if [ "X$DO_EXECUTE" = "X1" ] ; then
		du -s -k $CHECK_PATH
	fi
	if [ "X$DO_EXECUTE" = "X1" ] ; then
		du -a -k $CHECK_PATH | sort -r -n | head -n 10
	fi
}

function totalSize
{
	OPTIND=1
	USAGE1="totalSize [[-p] <path>] [-h]"
	CHECK_PATH=$1
	DO_EXECUTE=1
	while getopts "p:h" OPTION; do
            case ${OPTION} in
                p) CHECK_PATH=${OPTARG} ;;
                h) echo "${USAGE1}" 
		   DO_EXECUTE=0 ;;
                *) echo "${USAGE1}" 
		   DO_EXECUTE=0 ;;
            esac
	done
	if [ "X$DO_EXECUTE" = "X1" ] ; then
		SZ=`du -s -k $CHECK_PATH | awk '{s+=$1} END {printf "%.0f", s*1024 }'`
		echo -e "size of \e[1m$CHECK_PATH\e[0m in bytes: \e[31m$SZ\e[0m"
	fi
}

function findLongLines
{
        OPTIND=1
	USAGE1="findLongLines [-d <dir>] [-f <filenamePattern>] [-h]"
	USAGE2="         -d : root directory from where to start, default: ${PWD}"
	USAGE3="         -l : minimal length of line, default: 1024"
	USAGE4="         -f : filter files by pattern, default: all files. note: escape wildcards!"
	USAGE5="         -h : this help message"

	FIND_DIR=${PWD}
	MIN_LENGTH=1024
	FILE_PATTERN=
	DO_EXECUTE=1

	while getopts "d:l:f:h" OPTION; do
            case ${OPTION} in
                d) FIND_DIR=${OPTARG} ;;
                l) MIN_LENGTH=${OPTARG} ;;
                f) FILE_PATTERN="${OPTARG}" ;;
                h) echo "${USAGE1}"
                   echo "${USAGE2}"
                   echo "${USAGE3}"
                   echo "${USAGE4}"
                   echo "${USAGE5}"
                   DO_EXECUTE=0 ;;
                *) echo "${USAGE1}"
                   echo "${USAGE2}"
                   echo "${USAGE3}"
                   echo "${USAGE4}"
                   echo "${USAGE5}"
                  DO_EXECUTE=0 ;;
            esac
	done
	if [ "X${DO_EXECUTE}" = "X1" ] ; then
		AWK_COMMAND="BEGIN{ FS=\"\n\"; LINE=0; }{ if(length(\$1)>${MIN_LENGTH}) printf(\"%s(%d): length=%d\n\",FILENAME,LINE,length(\$1)); LINE=LINE+1; }"
		if [ "X$FILE_PATTERN" = "X" ] ; then
			find ${FIND_DIR} | xargs -I_ awk "${AWK_COMMAND}" _
		else
			find ${FIND_DIR} -name "${FILE_PATTERN}" | xargs -I_ awk "${AWK_COMMAND}" _
		fi
	fi
}

function processSize
{
        OPTIND=1
	USAGE1="processSize [-p <ppid> ] [ -i <filter IN string>] [ -o <filter OUT string>] [-h]"
	USAGE2="         -p : process id"
	USAGE3="         -i : filter in string"
	USAGE4="         -o : filter out string"
	USAGE5="         -h : this help message"

	FIND_DIR=${PWD}
	DO_EXECUTE=1

	while getopts "p:i:o:h" OPTION; do
            case ${OPTION} in
                p) PPID=${OPTARG} ;;
                i) FILTER_IN="${OPTARG}" ;;
                i) FILTER_OUT="${OPTARG}" ;;
                h) echo "${USAGE1}"
                   echo "${USAGE2}"
                   echo "${USAGE3}"
                   echo "${USAGE4}"
                   echo "${USAGE5}"
                   DO_EXECUTE=0 ;;
                *) echo "${USAGE1}"
                   echo "${USAGE2}"
                   echo "${USAGE3}"
                   echo "${USAGE4}"
                   echo "${USAGE5}"
                  DO_EXECUTE=0 ;;
            esac
	done
	if [ "X$FILTER_IN" = "X1" ] ; then
	    if [ "X$FILTER_OUT" = "X1" ] ; then
		ps -a | egrep -v "egrep" | cut -f7 -d' ' | xargs -I_ cat /proc/_/status | egrep -i "vmsize|pid" | egrep -v "PPid|Tracer"
	    else
		ps -a | egrep -v "${FILTER_OUT}|egrep" | grep Daem | cut -f7 -d' ' | xargs -I_ cat /proc/_/status | egrep -i "vmsize|pid" | egrep -v "PPid|Tracer"
	    fi

	else
	    if [ "X$FILTER_OUT" = "X1" ] ; then
	        ps -a | egrep -v "egrep" | grep ${FILTER_IN} | cut -f7 -d' ' | xargs -I_ cat /proc/_/status | egrep -i "vmsize|pid" | egrep -v "PPid|Tracer"

	    else
	        ps -a | egrep -v "${FILTER_OUT}|egrep" | grep ${FILTER_IN} | cut -f7 -d' ' | xargs -I_ cat /proc/_/status | egrep -i "vmsize|pid" | egrep -v "PPid|Tracer"

	    fi

	fi
}

function doValgrind()
{
        OPTIND=1
	USAGE1="doValgrind executable [ ... ]"
	LABEL=$1
	ROOT_PATH="."
	EXECUTABLE=$1

	if [ "${EXECUTABLE}" = "X" ] ; then
		echo "No executable defined"
		echo "Usage: ${USAGE1}"
	else
		if [ "X${IS_LINUX}" = "XLinux" ] ; then
			echo "writing log to ./${EXECUTABLE}.valgrindLog"
			/data/tecindev/tools/mot/netbeans/valgrind/bin/valgrind --tool=memcheck  \
        			 --leak-check=full \
        			 --track-origins=yes \
        			 --verbose \
        			 --trace-children=yes \
        			 --vgdb=yes \
        			 --fullpath-after= \
        			 --read-var-info=yes \
        			 --log-file=./${EXECUTABLE}.valgrindLog \
        			 $*

		fi
	fi
}

taskBranch ()
{
	local OPTIND verbose=0
	FINISH=N
	DRY_RUN=

	USAGE="usage: taskBranch -t <${EFGRN}task-name without prefix${ERS}> [-f \
<${EFCYN}feature-branch without prefix${ERS}>] [-g | -y] [-d)]\n\
\t${EFYEL}-t${ERS} : name of the task-branch\n\
\t${EFYEL}-f${ERS} : name of the feature-branch\n\
\t${EFYEL}-d${ERS} : do a dry-run: do not execute commands - just show them\n\
\te.g.: taskBranch -t ${EFGRN}myTask/xyz${ERS} -f ${EFCYN}myFeat${ERS} -y\n\
\t\tcreates ${EFRED}local${ERS}:\t\ttask/${EFGRN}myTask/xyz${ERS}  as branch of\n\
\t\t${EFRED}remote${ERS}:\t\t\torigin/feature/${EFCYN}myFeat${ERS} and\n\
\t\ttracking ${EFRED}upstream${ERS}:\torigin/task/${EFGRN}myTask/xyz${ERS}\n"

	while getopts t:f:ygd option
	do
		case "${option}"
		in
			t) TASK_ARG=${OPTARG};;
			f) FEATURE_ARG=${OPTARG};;
			d) DRY_RUN="echo -e " ;;
			*) echo $USAGE
			   FINISH=Y;;
		esac
	done

	if [ "X$FINISH" == "XN" ] ; then
			FEAT=feature

    if [ "X$1" == "X" ] ; then
			echo -e $USAGE
		else
			ORIGIN=""
			if [ "X$FEATURE_ARG" == "X" ] ; then
				ORIGIN="$FEAT/$TASK_ARG"
			else
				ORIGIN="$FEAT/$FEATURE_ARG"
			fi
			# first checkout the origin and get all the latest
			${DRY_RUN} git checkout $ORIGIN
			${DRY_RUN} git pull

			# now create branch and check it out
			${DRY_RUN} git checkout -b tasks/$TASK_ARG

			# make known to others
			${DRY_RUN} git push -u origin tasks/$TASK_ARG

			${DRY_RUN} git remote add tasks/$TASK_ARG tasks/$TASK_ARG
			${DRY_RUN} git branch -vv
		fi
	fi    
}

jiraBranch ()
{
        local OPTIND verbose=0
        FINISH=N
        DRY_RUN="echo -e "
        CURRENT_DIR=`pwd`
        REPO_DIR=~/Repos/MyRepo
        BASE_BRANCH=develop
        JIRA_TEXT="some text"
        BRANCH_NAME="${BASE_BRANCH}/${JIRA_TEXT// /-}"

        USAGE="usage: jiraBranch -j <${EFGRN}'JIRA-number and header'${ERS}> [-r repo-directory] [-b <${EFGRN}base-branch${ERS}>] [-e)xecute]\n\
\t${EFYEL}-j${ERS} : JIRA-number and the header of the task\n\
\t${EFYEL}-r${ERS} : directory of the repo, defaults to '${REPO_DIR}'\n\
\t${EFYEL}-b${ERS} : based on branch, defaults to 'develop'\n\
\t${EFYEL}-e${ERS} : execute commands, by default do a dry-run: just show commands that will be executed\n\
\te.g.: taskBranch -j ${EFGRN}'JIRA_123 Add XYZ-feature'${ERS}\n\
\t\tcreates ${EFRED}local${ERS}:\t\t${EFGRN}${BRANCH_NAME}${ERS}  as branch of\n\
\t\t${EFRED}remote${ERS}:\t\t\torigin/${EFCYN}develop${ERS} and\n\
\t\ttracking ${EFRED}upstream${ERS}:\torigin/${EFGRN}${BRANCH_NAME}${ERS}\n"

        while getopts j:b:r:he option
        do
                case "${option}"
                in
                        j) JIRA_TEXT=${OPTARG};;
                        j) REPO_DIR=${OPTARG};;
                        e) DRY_RUN="" ;;
                        h) echo -e $USAGE
                           FINISH=Y;;
                        *) echo -e $USAGE
                           FINISH=Y;;
                esac
        done

        if [ "X$FINISH" == "XN" ] ; then
                echo -e "${EFGRN} ### change directory to ${REPO_DIR}...${EFWHT}"
                BRANCH_NAME="${JIRA_TEXT// /-}"
                ${DRY_RUN} cd ${REPO_DIR}
                # first checkout the origin and get all the latest
                echo -e "${EFGRN} ### checkout base branch '${BASE_BRANCH}'...${EFWHT}"
                ${DRY_RUN} git checkout ${BASE_BRANCH}
                echo -e "${EFGRN} ### update base branch '${BASE_BRANCH}'...${EFWHT}"
                ${DRY_RUN} git pull
                # create the branch and push to upstream
                echo -e "${EFGRN} ### create task-branch branch '${BRANCH_NAME}'...${EFWHT}"
                ${DRY_RUN} git checkout -b ${BRANCH_NAME}
                echo -e "${EFGRN} ### push to remote '${BRANCH_NAME}'...${EFWHT}"
                ${DRY_RUN} git push origin HEAD
                echo -e "${EFGRN} ### change directory to ${CURRENT_DIR}...${EFWHT}"
                ${DRY_RUN} cd ${CURRENT_DIR}

        fi

}

listBranches ()
{
	git for-each-ref --format='%(color:cyan)%(authordate:format:%m/%d/%Y %I:%M %p)    %(align:25,left)%(color:yellow)%(authorname)%(end) %(color:reset)%(refname:strip=3)' --sort=authordate refs/remotes
}

listRemoteBranches ()
{
	git for-each-ref \
		--format='%(color:cyan)%(authordate:format:%m/%d/%Y %I:%M %p)    %(align:25,left)%(color:yellow)%(authorname)%(end) %(color:reset)%(refname:strip=3)' \
		--sort=authordate refs/remotes |\
		grep Kybelksties

}

deleteLocal ()
{
	for b in $*; do
		# delete branch locally
		echo deleting local branch: ${b}
		git branch -d ${b}
	done
}

deleteRemote ()
{
	for b in $*; do
		# delete branch remotely
		echo deleting remote branch: ${b}
		git push origin --delete ${b}
	done
}

deleteBranches ()
{
	deleteLocal $*
	deleteRemote $*
}

upstream ()
{
	while read branch; do
		upstream=$(git rev-parse --abbrev-ref $branch@{upstream} 2>/dev/null)
		if [[ $? == 0 ]]; then
			echo $branch tracks $upstream
		else
			echo $branch has no upstream configured
		fi
	done < <(git for-each-ref --format='%(refname:short)' refs/heads/*)

}

findTests ()
{
	set ROOT_DIR="/root/directory"
	set BRANCH_TO_CHECK=master

	cd ${ROOT_DIR}
	#git checkout ${BRANCH_TO_CHECK} 2>&1 > /dev/null

	set COMP_TEST_DIRS=\
	"${ROOT_DIR}/sub1" \
	"${ROOT_DIR}/sub2" \
	"${ROOT_DIR}/sub3" \
	"${ROOT_DIR}/sub4"

	echo "<html>"
	echo "<head> <title> Found Component tests </title> </head>"

	echo "<body>"
	find ${COMP_TEST_DIRS} -name "*.java" | \
		xargs egrep -A 1 "^[[:space:]]*@Test|^[[:space:]]*package[[:space:]]" | \
		egrep -v "@Test|\-[[:space:]]*$" | \
		sed "s/-[[:space:]]/:/g" | \
		sed "s/:[[:space:]]/:/g" | \
		sed "s/;//g" | \
		awk -v pkg='####' 'BEGIN { FS=":";OFS=";";}{ if ( match($2,"package ") ) { pkg=substr($2,RSTART+RLENGTH); } else { print $1, pkg, $2 } }' | \
		tr "/" "\\" | \
		sed "s/^[\\]d/D:/g" | \
		awk 'BEGIN {FS=";";} \
		{ match($3,/[a-zA-Z0-9_]+\(\)/); \
		 testFunction=substr($3,RSTART,RLENGTH); \
		 fileLink="\"file:///" $1 "#:~:text=" testFunction "\""; \
		 displayLink=$2"."testFunction; \
		 print "<a href=" fileLink " target=\"_blank\">" displayLink "</a><br>"; }'

	echo "</body>"

	echo "</html>"

}

EXECUTING_USER=$(whoami)
CURRENT_RED_HAT_RELEASE="$(cat /etc/redhat-release)"
IS_RED_HAT_7=$(if [[ $(cat /etc/redhat-release) == "Red Hat"*"release 7"* ]]; then echo Yes; else echo No; fi)
IS_RED_HAT_8=$(if [[ $(cat /etc/redhat-release) == "Red Hat"*"release 8"* ]]; then echo Yes; else echo No; fi)

# set the Linux commands ignoring functions and aliases
WHICH_="which --skip-alias --skip-functions"
AWK_=$(${WHICH_} awk)
SED_=$(${WHICH_} sed)
GREP_=$(${WHICH_} grep)
EGREP_=$(${WHICH_} egrep)
PS_=$(${WHICH_} ps)
SLEEP_=$(${WHICH_} sleep)
STRINGS_=$(${WHICH_} strings)
ECHO_="$(${WHICH_} echo)"

# term-cap colors, default to empty
bold=""
ul=""
eul=""
rev=""
blink=""
invis=""
em=""
eem=""
black=""
red=""
green=""
yellow=""
blue=""
magenta=""
cyan=""
white=""
normal=""
bblack=""
bred=""
bgreen=""
byellow=""
bblue=""
bmagenta=""
bcyan=""
bwhite=""
bnormal=""
err_col=""
warn_col=""
info_col=""
header_col=""
debug_col=""
even_col=""
odd_col=""
h_even_col=""
h_odd_col=""
reset=""

# term-cap colors, if colors are supported
case ${TERM} in
'' | 'dumb' | 'unknown') ;; # use default empty term-caps
*)                          # use minimal term-caps for other $TERM types
     bold=$(tput bold)
     ul=$(tput smul)
     eul=$(tput rmul)
     rev=$(tput rev)
     blink=$(tput blink)
     invis=$(tput invis)
     em=$(tput smso)
     eem=$(tput rmso)
     black=$(tput setaf 0)
     red=$(tput setaf 1)
     green=$(tput setaf 2)
     yellow=$(tput setaf 3)
     blue=$(tput setaf 4)
     magenta=$(tput setaf 5)
     cyan=$(tput setaf 6)
     white=$(tput setaf 7)
     normal=$(tput setaf 9)
     bblack=$(tput setab 0)
     bred=$(tput setab 1)
     bgreen=$(tput setab 2)
     byellow=$(tput setab 3)
     bblue=$(tput setab 4)
     bmagenta=$(tput setab 5)
     bcyan=$(tput setab 6)
     bwhite=$(tput setab 7)
     bnormal=$(tput setab 9)

     err_col=${bred}${yellow}
     warn_col=${bold}${byellow}${black}
     info_col=${bold}${green}
     header_col=${bold}${yellow}
     debug_col=${bold}${rev}
     usage_col=${bold}${yellow}
     even_col=${green}
     odd_col=${magenta}
     h_even_col=${white}
     h_odd_col=${cyan}

     reset=$(tput sgr0)${eul}${eem}
     ;;
esac

function printError() {
     printf "%s" "${err_col}ERROR:${reset} "
     ODD=No
     for part in "$@"; do

          if [ "${ODD}X" = "YesX" ]; then
               printf "%s" "${odd_col}${part}${reset}"
               ODD=No
          else
               printf "%s" "${even_col}${part}${reset}"
               ODD=Yes
          fi
     done
     printf "\r\n%s\r\n" "${yellow}Exiting.${reset}"
}

function printWarning() {
     printf "%s" "${warn_col}WARNING:${reset} "
     ODD=No
     for part in "$@"; do

          if [ "${ODD}X" = "YesX" ]; then
               printf "%s" "${odd_col}${part}${reset}"
               ODD=No
          else
               printf "%s" "${even_col}${part}${reset}"
               ODD=Yes
          fi
     done
     printf "%s\r\n" ""
}

function printInfo() {
     printf "%s" "${info_col}INFO:${reset} "
     ODD=No
     for part in "$@"; do

          if [ "${ODD}X" = "YesX" ]; then
               printf "%s" "${odd_col}${part}${reset}"
               ODD=No
          else
               printf "%s" "${even_col}${part}${reset}"
               ODD=Yes
          fi
     done
     printf "%s\r\n" ""
}

function printDebug() {
     printf "%s" "${debug_col}DEBUG:${reset} "
     ODD=No
     for part in "$@"; do

          if [ "${ODD}X" = "YesX" ]; then
               printf "%s" "${odd_col}${part}${reset}"
               ODD=No
          else
               printf "%s" "${even_col}${part}${reset}"
               ODD=Yes
          fi
     done
     printf "%s\r\n" ""
}

function printLine() {
     ODD=No
     for part in "$@"; do
          if [ "${ODD}X" = "YesX" ]; then
               printf "%s" "${odd_col}${part}${reset}"
               ODD=No
          else
               printf "%s" "${even_col}${part}${reset}"
               ODD=Yes
          fi
     done
     printf "%s\r\n" ""
}

function printHeader() {
     ODD=No
     HEADER=""
     LEN=0
     for part in "$@"; do
          LEN=$((LEN+${#part}))
          if [ "${ODD}X" = "YesX" ]; then
               HEADER="${HEADER}${h_odd_col}${part}"
               ODD=No
          else
               HEADER="${HEADER}${h_even_col}${part}"
               ODD=Yes
          fi
     done
     EDGE_LEN=$(((100 - LEN) / 2))
     EDGE=$(head -c $((EDGE_LEN)) </dev/zero | tr '\0' '#')
     printf "%s %s %s\r\n" "${header_col}${EDGE}${reset}" "${HEADER}" "${header_col}${EDGE}${reset}"
}

function frame() {
     LINE=$*
     TOP_BOTTOM=\+$(head -c $(($(echo "${LINE}" | wc -m) + 1)) </dev/zero | tr '\0' '-')\+
     printf "%s\r\n" "${TOP_BOTTOM}"
     printf "| %s |\r\n" "${LINE}"
     printf "%s\r\n" "${TOP_BOTTOM}"
}

# facility to fail a script upon failure of commands/groups of commands
# usage: (bash commands... ) || failThisScript "<error message>" [optional error-code]
function failThisScript() {
     cmd_success=$?
     fail_reason="$1"
     if [ "$2X" != "X" ]; then
          # override error code of last command
          cmd_success=$2
     fi
     if [ "${cmd_success}X" != "0X" ]; then
          printError "${fail_reason}. Code ${cmd_success}."
          # exit with the error code of the last command or custom code, in case it was passed in
          exit $((cmd_success))
     fi
}

# make sure the given parameter does not evaluate to "" or "/"
# "return" the valid absolute directory-path
# also reject "INVALID_{...} directories"
function setValidAbsoluteDir() {
     DIR=$1
     [[ "${DIR}" != "INVALID_"* ]] || DIR="${DIR}"
     [ "${DIR}X" != "X" ] || DIR="INVALID_EMPTY"
     [ "${DIR}X" != "/X" ] || DIR="INVALID_ROOT"
     [[ "${DIR}" != "INVALID_"* ]] && realpath "${DIR}" >/dev/null 2>&1 && DIR=$(realpath ${DIR}) 
     [[ "${DIR}" != "INVALID_"* ]] && DIR="$(dirname "${DIR}")/$(basename "${DIR}")"
     ${ECHO_} "${DIR}/"
}

# create the directory if possible, cleans it and returns the real path
function createEmptyDir() {
     DIR=$(setValidAbsoluteDir "$1")
     [[ "${DIR}" != "INVALID_"* ]] || exit 1
     # remove it and all contents and re-create it
     rm -rf "${DIR}"
     mkdir -p "${DIR}"
     ${ECHO_} "${DIR}"
}


function pushDir() {
     NEW_DIR=${1}
     [ "${NEW_DIR}X" != "X" ] ||
          failThisScript "Cannot change directory - no directory given"
     pushd "${1}" >/dev/null 2>&1 ||
          failThisScript "Cannot change into '${NEW_DIR}'"
}

function popDir() {
     popd >/dev/null 2>&1 ||
          failThisScript "Cannot return to previous directory"
}

function copy() {
     cp -R "$1" "$2" ||
          failThisScript "Cannot copy '$1' to '$2'"
}

INSTALL_TOOL=$(if [ "${IS_UBUNTU}" = "Yes" ]; then echo "apt-get"; else echo "yum"; fi)
function installPackage() {
     if [ "${1}X" != "X" ]; then
          ${INSTALL_TOOL} install -y "$1" || failThisScript "Could not ${INSTALL_TOOL} install '$1'"
     fi
}

function removePackage() {
     if [ "${1}X" != "X" ]; then
          ${INSTALL_TOOL} remove -y "$1" || failThisScript "Could not ${INSTALL_TOOL} remove '$1'"
     fi
}



