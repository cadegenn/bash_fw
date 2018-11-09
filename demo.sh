#!/bin/bash

## @file skel.rc
## @brief		skeleton file for new script.
## 				Just copy this file to a new script.sh to begin coding
## @author		Charles-Antoine Degennes <cadegenn]gmail.com>
## @copyright	Copyright (C) 2015-2016  Charles-Antoine Degennes <cadegenn@gmail.com>

# 
# This file is part of TinyBashFramework
# 
#     TinyBashFramework is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     TinyBashFramework is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with TinyBashFramework.  If not, see <http://www.gnu.org/licenses/>.
# 
#
#

## @var BASENAME
## @brief basename of the current script being run
declare BASENAME=

## @var DIRNAME
## @brief absolute pathname of the current script being run
declare DIRNAME=

# compute absolute path of caller
if [ -L "$0" ]; then
	BASENAME=$(basename "${SCRIPTNAME}")
	DIRNAME=$(cd "`dirname "${SCRIPTNAME}"`"; pwd)
else
	BASENAME=$(basename "$0")
	DIRNAME=$(cd `dirname "$0"`; pwd)
fi

## @var BASHFW_PATH
## @brief path to installed bash framework
declare BASHFW_PATH=

# try to find BASHFW_PATH in reversed-precedence order
# 99. ${DIRNAME} (default value)
BASHFW_PATH="${DIRNAME}"
# 1. /etc/profile.d/bashfw.sh
[ -e /etc/profile.d/bashfw.sh ] && . /etc/profile.d/bashfw.sh

## @var QUIET
## @brief instruct script to print nothing
## @note	QUIET supersedes all other log level informations like VERBOSE, DEBUG and DEVEL
##			However, it can still log to a file or to a syslog if defined
## @note	QUIET imply YES. So be careful specifying default values.
declare QUIET=

## @var VERBOSE
## @brief instruct script to print verbose informations
declare VERBOSE=

## @var DEBUG
## @brief instruct script to print debug informations
declare DEBUG=

## @var DEVEL
## @brief instruct script to print development informations
declare DEVEL=

## @var YES
## @brief if not empty assume 'yes' to all questions
declare YES=

## @var ASK
## @brief if not empty ask for confirmation before anything is executed
declare ASK=

## @var BASHFW_THEME
## @brief specify color theme for pretty output
declare BASHFW_THEME=ansi

## @var ARGV
## @brief array of user parameters
declare -a ARGV

## @var TRACE
## @brief instruct script to print stack trace on error
## @note  stack trace is always displayed on fatal error
declare TRACE=

## @fn usage()
## @brief Print usage informations (help screen)
usage() {
	cat <<- EOF
		COMMON PARAMETERS: ${BASENAME} [-u -q -v -d -dev -ask -y -s -nc -theme theme]
		 	-u		common usage screen (this screen)
		 	-q		quiet: do not print anything to the console
		 	-v		verbose mode: print more messages
		 	-d		debug mode: print VARIABLE=value pairs
		 	-dev	devel mode: print additional development data
		 	-ask	ask for user confirmation for each individual eexec() call
		 			NOTE: it is not affected by -y
			-trace	print stack trace on error
		 	-y		assume 'yes' to all questions
		 	-s		simulate: do not really execute commands
		 	-nc		no color. Do not use color theme.
		 			-nc is a shortcut for -theme nocolor
		 	-theme 	use specified theme as color scheme.
		 			use '-theme list' to list available themes.
		 	-api	use bash_fw from alternate directory (for developers only).

	EOF
}

# Clean som stuff on exit
onExit() {
	set -e
	[ -e ${TMP} ] && rm -Rf ${TMP}
}

# Set traps
trap onExit HUP INT KILL TERM EXIT

# parse command line
while [ $# -gt 0 ]; do
	case $1 in
		-q)		QUIET=true
				ASK=
				YES=true
				VERBOSE=
				DEBUG=
				DEVEL=
				;;
		-v)		VERBOSE=true
				;;
		-d)		DEBUG=true
				VERBOSE=true
				;;
		-dev)	DEVEL=true
				DEBUG=true
				VERBOSE=true
				;;
		-u)		usage
				;;
		-y)		YES=true
				;;
		-ask)	ASK=true
				;;
		-trace)	TRACE=true
				;;
		-s)		SIMULATE=true
				;;
		-nc)	BASHFW_THEME="nocolor"
				;;
		-theme)	shift
				case "${1}" in
					list)
							find ${BASHFW_PATH}/lib/ -name "theme_*.rc" -printf "%f\n" | cut -d '_' -f2 | cut -d '.' -f1 | tr -s '\n' ' '
							echo # if this echo is not present, the above line do not display anything
							;;
					*)		BASHFW_THEME="${1}"
							;;
				esac
				;;
		-api)	shift
				BASHFW_PATH=${1}
				;;
		*)		# store user-defined command line-arguments
				ARGV=("${ARGV[@]}" "${1}")
				;;
	esac
	shift
done

# load API
source "${BASHFW_PATH}/lib/api.rc" || {
	echo "${BASHFW_PATH}/lib/api.rc not found... Aborting."
	exit 1
}

## @fn main()
## @brief	function containing main program
main() {


	eenter "${FUNCNAME}()"
	#################################################
	##
	## YOUR SCRIPT GOES HERE !
	##
	##################################################
	
	edevel "TERM = ${TERM}"
	edevel "STDOUT = ${STDOUT}"
	edevel "TTY = ${TTY}"
	edevel "HAVE_TTY = ${HAVE_TTY}"
	edevel "VERBOSE = ${VERBOSE}"
	edevel "DEBUG = ${DEBUG}"
	edevel "DEVEL = ${DEVEL}"
	edevel "ASK = ${ASK}"
	edevel "YES = ${YES}"
	edevel "SIMULATE = ${SIMULATE}"
	edevel "TRACE = ${TRACE}"

	ebreak

	# print messages in invert-precedence order 
	etitle "This is a title"
	esubtitle "This is a subtitle #1"

	einfo "Informations"
	ebegin "Begining long process"
	eend $?
	everbose "Verbose output"
	edebug "Debug output"
	edevel "Developpment output"

	esubtitle "This is a subtitle #2"
	# print exec command
	eexec "ping -c 1 localhost"
	ebegin "ping localhost"
	eexec "ping -c 1 localhost"
	eend $?

	esubtitle "This is a subtitle #3"
	# print questions
	local rep=$(equestion "This is a question. Are you agree ?")
	local rep=$(equestion "Another question with default answer ?" "anwser")
	local rep=$(equestion_yn "Default reponse is yes ?" "y")
	edebug "rep = ${rep}"
	local rep=$(equestion_yn "Default reponse is no (empty) ?" "n")
	edebug "rep = ${rep}"
	local rep=$(equestion_passwd "What is the passwd ?" "" true)

	# print warning and errors
	ewarn "/!\\ ATTENTION !!"
	eerror "An error has occured"

	source "${DIRNAME}/demo.rc"


	##################################################
	##
	## YOUR SCRIPT END HERE !
	##
	##################################################
	eleave "${FUNCNAME}()"

}

main
echo
