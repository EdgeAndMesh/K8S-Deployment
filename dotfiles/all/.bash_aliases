alias bat=batcat
alias df='df --human-readable'
alias diff='diff --color=auto'
alias du='du --human-readable'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias free='free --human --wide --total'
alias fzf='fzf --preview "batcat --color=always --style=numbers --line-range=:500 {}"'
alias grep='grep --colour=auto'
alias ip='ip --color=auto'
alias kernel='uname --kernel-release'
alias la='ls -l --human-readable --all'
alias lA='ls -l --human-readable --almost-all'
alias ll='ls -l --human-readable'
alias lower='tr [:upper:] [:lower]'
alias lsblk-label='lsblk -o name,fstype,mountpoint,label,partlabel,size'
alias ls='ls --color=auto'
alias mkdir='mkdir --parents --verbose'
alias more=less
alias mv='mv --verbose'
alias port='netstat --tcp --udp --listening --all --numeric --program --wide'
alias publicIP='printf "%s\n" "$(curl --silent ifconfig.me)"'
alias :q='exit'
alias rmdir='rmdir --verbose'
alias rm='rm --verbose'
alias ssh-agentd='eval $(ssh-agent -s)'
alias terminal="\$TERMINAL"
alias upper='tr [:lower:] [:upper:]'
alias youtube-dl='yt-dlp'
alias ytdownload='yt-dlp --embed-subs --all-subs --embed-thumbnail --embed-metadata \
	--embed-chapters'

# ex - archive extractor
# usage: ex <file>
ex ()
{
	if [ -f "$1" ]
	then
		case $1 in
			*.tar.bz2)   tar xjf "$1"    ;;
			*.tar.gz)    tar xzf "$1"    ;;
			*.bz2)       bunzip2 "$1"    ;;
			*.rar)       unrar x "$1"    ;;
			*.gz)        gunzip "$1"     ;;
			*.tar)       tar xf "$1"     ;;
			*.tbz2)      tar xjf "$1"    ;;
			*.tgz)       tar xzf "$1"    ;;
			*.zip)       unzip "$1"      ;;
			*.Z)         uncompress "$1" ;;
			*.7z)        7z x "$1"       ;;
			*)           echo "'$1' cannot be extracted via ex()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

help() {
	"$@" --help 2>&1 | bat --plain --language=help
}

# vim:ft=sh
