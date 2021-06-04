#!/usr/bin/bash

alias l="ls -Fax"
alias ll="ls -Fasl"
alias v=vim
alias m=less
alias cls=clear
alias findExe="find . -perm -u+x -type f "
alias h=history
alias showBranch="git branch -vv"
alias fetchAll="git fetch --all"
export GREP_OPTIONS=--color
export GREP_COLORS="ms=01;31:mc=01;31:sl=:cx=:fn=36:ln=32:bn=32:se=36"

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

PS1="$HC$FYEL[$FMAG\A$FRED$(__git_ps1) $FCYN${debian_chroot:+($debian_chroot)}\u$FYEL: $FBLE\w $FYEL> $RS"
PS2="$HC$FYEL&gt; $RS"

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
