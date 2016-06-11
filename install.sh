#!/bin/bash
VERSION="v0.1"
BASE_DIR=`dirname $0`
cd "${BASE_DIR}"
BASE_DIR="${PWD}"

function log {
	printf '\e[1;33m%*s\e[0m' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	printf '\r\e[1;33m-- \e[1;32m%s \e[0m\n' "$*"
}

function install_i3 {
	[ -L "${HOME}/.i3" ] && rm -v "${HOME}/.i3"
	ln -sivT "${BASE_DIR}/i3" "${HOME}/.i3"
}

function install_tmux {
	[ -L "${HOME}/.tmux.conf" ] && rm -v "${HOME}/.tmux.conf"
	ln -sivT "${BASE_DIR}/tmux/tmux.conf" "${HOME}/.tmux.conf"
}

function install_zsh {
	cd "${BASE_DIR}/zsh"
	[ ! -d "oh-my-zsh" ] && git clone --recursive https://github.com/robbyrussell/oh-my-zsh
	cd "oh-my-zsh"
#	git pull && git fetch --recurse-submodules && git submodule foreach git pull origin master
	git pull && git submodule update --init --recursive
	cd "${BASE_DIR}/zsh"
	for file in oh-my-zsh zshrc; do
		[ -L "${HOME}/.${file}" ] && rm -v "${HOME}/.${file}"
		ln -sivT "`readlink -f ${file}`" "${HOME}/.${file}"
	done
	[ -f ~/.envConf ] && [ "`head -n1 ~/.envConf`"="# zsh config file (pi ${VERSION})" ] && source ~/.envConf ||
		mv -vi --backup ~/.envConf ~/.envConf_`date +%F_%H%M%S`

	[ -z "$PUSHOVER_API_URL" ] && PUSHOVER_API_URL="https://api.pushover.net/1/messages.json"
	[ -z "$PUSHOVER_API_USER" ] && read -p "please enter your pushover user id: " PUSHOVER_API_USER
	[ -z "$PUSHOVER_API_TOKEN" ] && read -p "please enter your pushover api token: " PUSHOVER_API_TOKEN
	[ -z "$ZSH_THEME" ] && read -p "please enter the zsh theme you wanna use(to use 'bira' just hit enter): "
	[ -z "$ZSH_THEME" ] && ZSH_THEME="bira"

	local ZSH_CUSTOM="${BASE_DIR}/zsh/custom"
	echo "# zsh config file (pi $VERSION)" >~/.envConf
	echo "# vim: ft=sh" >>~/.envConf
	echo "ZSH_CUSTOM=\"$ZSH_CUSTOM\"" >>~/.envConf
	echo "ZSH_THEME=\"$ZSH_THEME\"" >>~/.envConf
	echo "PUSHOVER_API_URL=\"$PUSHOVER_API_URL\"" >>~/.envConf
	echo "PUSHOVER_API_USER=\"$PUSHOVER_API_USER\"" >>~/.envConf
	echo "PUSHOVER_API_TOKEN=\"$PUSHOVER_API_TOKEN\"" >>~/.envConf
}

function insall_x11 {
	cd "${BASE_DIR}/X"
	ln -sivT "Xresources" "${HOME}/.Xresources"
	ln -sivT "xinitrc" "${HOME}/.xinitrc"
	ln -sivT "xsession" "${HOME}/.xsession"
}

function install_git {
	git config --global user.email "git-contact@mr-pi.de"
	git config --global user.name "Mr. Pi"
}

function install_vim {
	[ -L "${HOME}/.vim" ] && rm -v "${HOME}/.vim"
	ln -sivT "${BASE_DIR}/vim" "${HOME}/.vim"
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	local TMP_VIMRC=`mktemp`
	echo "set nocompatible" >$TMP_VIMRC
	echo "filetype off" >>$TMP_VIMRC
	echo "call plug#begin('~/.vim/bundle')" >>$TMP_VIMRC
	grep "^Plug " "${BASE_DIR}/vim/vimrc" >>$TMP_VIMRC
	echo "call plug#end()" >>$TMP_VIMRC
	vim -u "${TMP_VIMRC}" +PlugUpgrade +PlugInstall +PlugUpdate +qall
	rm -v $TMP_VIMRC
}

for job in i3 tmux zsh git vim x11; do
	log "installing configuration for '$job'"
	install_${job}
	cd "${BASE_DIR}"
done
log "Finish"
