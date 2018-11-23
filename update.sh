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
## @brief Print usage informations of common parameters
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
				TRACE=
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

	SKEL="${BASHFW_PATH}/skel.sh"

	help() {
		cat <<- EOF
			DESCRIPTION: ${BASENAME} update a script to the latest skeleton version
			USAGE: ${BASENAME} [-h -H] [-skel /path/to/skel.sh] -script /path/to/script.sh
			 	-h		show help (this screen)
			 	-H		show help (this screen) with common parameters usage
			 	-skel	full path to the reference to skeleton from Tiny Bash Framework ([${SKEL}])
			 	-script	ful path to custom script to update
		EOF
	}

	# parsing user-defined command line arguments
	while [ $# -gt 0 ]; do
	    case $1 in
			-h)
				help
				exit
				;;
			-H)
				help
				usage
				exit
				;;
			-skel)
				shift
				SKEL=${1}
				;;
			-script)
				shift
				SCRIPT=${1}
				;;
			*)	edevel "ARGV[1] = ${1}"
				;;
		esac
		shift
	done

	#################################################
	##
	## YOUR SCRIPT GOES HERE !
	##
	##################################################
	
	edevel "SKEL = ${SKEL}"
	edevel "SCRIPT = ${SCRIPT}"

	[ ! "${SKEL}" ] && efatal "No skeleton defined. Please select one. See help."
	[ ! "${SCRIPT}" ] && efatal "No script defined. Please select one. See help."

	# extract header of script
	eexec "awk '/^#!/,/^## @var BASENAME$/' ${SCRIPT} | head -n -1 > /tmp/$(basename ${SCRIPT}).00head"
	# extract current script content
	# SCRIPT_CONTENT=$(awk '/^main\(\)/,/^}/' ${SCRIPT})
	# edevel "SCRIPT_CONTENT = ${SCRIPT_CONTENT}"
	eexec "awk '/^main\(\)/,/^}/' ${SCRIPT} > /tmp/$(basename ${SCRIPT}).10main"

	# fetch lines no. of skel.sh of known anchors
	LINENO_HEAD_START=$(grep -n "^## @var BASENAME$" ${SKEL} | cut -d':' -f1)
	[ ! "${LINENO_HEAD_START}" ] && efatal "^## @var BASENAME anchor not found in script."
	LINENO_MAIN_START=$(grep -n "^main()" ${SKEL} | cut -d':' -f1)
	[ ! "${LINENO_MAIN_START}" ] && efatal "^main() anchor not found in script."
	for n in $(grep -n "^}$" ${SKEL} | cut -d':' -f1); do
		[ ${n} -lt ${LINENO_MAIN_START} ] && continue
	done
	LINENO_MAIN_END=${n}
	edevel "LINENO_HEAD_START = ${LINENO_HEAD_START}"
	edevel "LINENO_MAIN_START = ${LINENO_MAIN_START}"
	edevel "LINENO_MAIN_END = ${LINENO_MAIN_END}"

	# cut everything together
	# from beginning to line LINENO_MAIN_START
	# eexec "head -n $((LINENO_MAIN_START - 1)) '${SKEL}' > /tmp/$(basename ${SCRIPT}).head"
	# from LINENO_HEAD_START to LINENO_MAIN_START
	eexec "tail -n +$((LINENO_HEAD_START)) '${SKEL}' | head -n $((LINENO_MAIN_START - LINENO_HEAD_START)) > /tmp/$(basename ${SCRIPT}).02head"
	eexec "tail -n +$((LINENO_MAIN_END +1)) '${SKEL}' > /tmp/$(basename ${SCRIPT}).20tail"

	# backup original script
	eexec mv ${SCRIPT} ${SCRIPT}.bak || efatal "Unable to backup original script."
	# replace it by new version
	eexec "cat '/tmp/$(basename ${SCRIPT})'* > '${SCRIPT}'"
	eexec chmod 755 "${SCRIPT}"

	##################################################
	##
	## YOUR SCRIPT END HERE !
	##
	##################################################
	eleave "${FUNCNAME}()"

}

main "${ARGV[@]}"
unset ARGV
echo
