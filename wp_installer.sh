#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#				   WP installer script #
# (C)2017-2018 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#	Please keep my name in the credits #
################################################################################
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]	;	then bash "$0" "$@"	;	exit "$?"	;	fi
# Make sure only root can run this script
if [[ $EUID -ne 0 ]]	;	then echo "This script must be run as root"	;	exit 1	;	fi

init(){
	################### PROGRAM INFO ##########################################
	VER_MAJOR=0
	VER_MINOR=5
	VER_PATCH=70
	VER_STATE="PRE-ALPHA"
	BUILD=20180522
	###
	PROGRAM_SUITE="Pegasus' Linux Administration Tools"
	SCRIPT_TITLE="WordPress site installer"
	SCRIPT="${${basename "${BASH_SOURCE[0]}"}%.*}"
	INI_FILE="$SCRIPT.ini"
	MAINTAINER="Mattijs Snepvangers"
	MAINTAINER_EMAIL="pegasus.ict@gmail.com"
	LICENSE="MIT"
	CURR_YEAR=$(date +"%Y")
	COPYRIGHT="(C)2017-$CURR_YEAR - $MAINTAINER"
	PROGRAM="$PROGRAM_SUITE - $SCRIPT"
	SHORT_VER="Ver$VER_MAJOR.$VER_MINOR.$VER_PATCH-$VER_STATE"
	VER="$SHORT_VER build $BUILD"
	### DEFAULT VALUES ###
	VERBOSITY=3
	### CONSTANTS ###
	TODAY=$(date +"%d-%m-%Y")
	LOG_DIR="/var/log/plat"
	LOG_FILE="$LOG_DIR/WPinstaller_$START_TIME.log"
	TARGET_SCRIPT_DIR="/etc/plat"
	INC_DIR="lib"
	FUNCTIONS_LIB="functions.inc.sh"
	WP_FUNCTIONS_LIB="wp-$FUNCTIONS_LIB"
	INI_PARSER="iniparser.sh"
	### IMPORT FUNCTIONS ###
	source "$INC_DIR/$FUNCTIONS_LIB"
	source "$INC_DIR/WP_FUNCTIONS_LIB"
	### IMPORT INI PARSER, PARSE INI ###
	goto_base_dir
	source "$INC_DIR/$INI_PARSER"
	read_ini "$INI_FILE"
	get_args $@
}

main() {
	####### MAIN #####################################################################################
	apt-inst letsencrypt pwgen
	if [ GEN_RAND_PW == true ]
	then
		WP_DB_PASSWORD="$(gen_rnd_pw)"
		MYSQL_ROOT_PASSWORD="$(gen_rnd_pw)"
	fi
	### create directories if needed
	create_dir $LOG_DIR
	create_dir $TARGET_SCRIPT_DIR
	create_dir $WP_PATH
	purge_dir $WP_PUBLIC
	create_dir $WP_LOGS
	create_DB
	update_server_config
	install_ssl_certs
	install_wp
	secure_wp
}

init $@
main
