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

# load API
source "${DIRNAME}/lib/api.rc" || {
	echo "${DIRNAME}/lib/api.rc not found... Aborting."
	exit 1
}

# Print usage informations
usage() {
	cat <<- EOF
		DESCRIPTION: ${BASENAME} do some things
		USAGE: ${BASENAME} [-d] [-dev] [-h] [-y]
		 	-h	help screen (this screen)
		 	-d	debug mode: print VARIABLE=value pairs
		 	-dev	devel mode: print additional development data
		 	-ask	ask for user confirmation for each individual eexec() call
		 			NOTE: it is not affected by -y
		 	-y	assume 'yes' to all questions
		 	-s	simulate: do not really execute commands
		 	--update	update libraries from github
	EOF
	exit
}

# Update itself
update() {
	ebegin "Updating skel.sh"
	eexec wget --no-check-certificate -q https://raw.githubusercontent.com/cadegenn/API/master/bash/skel.sh -O ${DIRNAME}/skel.sh
	eend $?
	ebegin "Updating libraries"
	local FILES=$(find ${DIRNAME}/lib/ -mindepth 1 -type f -exec basename {} \;)
	for F in ${FILES}; do
		eexec wget --no-check-certificate -q https://raw.githubusercontent.com/cadegenn/API/master/bash/lib/${F} -O ${DIRNAME}/lib/${F}
	done
	eend $?
	exit
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
		-d)		DEBUG=true
				;;
		-dev)	DEVEL=true
				;;
		-h)		usage
				;;
		-y)		YES=true
				;;
		-ask)	ASK=true
				;;
		-s)		SIMULATE=true
				;;
		--update)
				update
				;;
	esac
	shift
done

#################################################
##
## YOUR SCRIPT GOES HERE !
##
##################################################



##################################################
##
## YOUR SCRIPT END HERE !
##
##################################################

