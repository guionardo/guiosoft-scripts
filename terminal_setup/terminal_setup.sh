#!/bin/bash

function msg {
    # https://ioflood.com/blog/bash-color/
    clear_color="\033[0m"
    case "$1" in
    error)
        color="\033[31m"
        shift 1
        ;;
    success)
        color="\033[32m"
        shift 1
        ;;
    warn)
        color="\033[33m"
        shift 1
        ;;
    info)
        color="\033[34m"
        shift 1
        ;;
    *)
        color=""
        clear_color=""
        ;;
    esac

    echo -e "$color$@$clear_color"
}

function check_sudo {
    if [ ! ${EUID} -eq 0 ]; then
        msg error "Por favor, execute este script como sudo"
        exit 1
    fi
}

function install_rust {
    cargo_version=$(cargo version)
    if [ "$?" == "0" ]; then
        msg success "Rust disponível: $cargo_version"
        return
    fi

    msg info "Instalando rust"

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    if [ $? != 0 ]; then
        msg error "Instalação do Rust não completou com sucesso! Verifique!"
    else
        msg warn "Feche este terminal e execute o comando novamente para que o PATH esteja atualizado"
    fi
    exit 1
}

function install_firacode_font {
    msg info "* Fira Code Font"
    fonts_dir="${HOME}/.local/share/fonts"
    mkdir -p "${fonts_dir}"

    fc=$(ls $fonts_dir/FiraCode*.ttf | wc -l)
    if [ $fc -gt 5 ]; then
        msg success "$(ls $fonts_dir/FiraCode*.ttf)"
        return
    fi

    sudo apt install jq unzip

    msg info "  - Obtendo última release de Fira Code"
    firacode_url_zip=$(curl -s https://api.github.com/repos/tonsky/FiraCode/releases/latest | jq '.assets[].browser_download_url' | grep '.zip')

    if [ $? != 0 ]; then
        msg error "Não foi possível identificar a última relase da fonte Fira Code"
        exit 1
    fi

    firacode_url_zip=$(echo $firacode_url_zip | sed 's/^"//;s/"$//')

    tmpzip=$(mktemp --suffix=firacode)

    msg info "  - Download: $firacode_url_zip"
    curl -o $tmpzip -L $firacode_url_zip
    file $tmpzip | grep "Zip archive"
    if [ $? -eq 0 ]; then
        msg info "  - Download OK"
        msg info "  - Unzipping"
        tmpzipfolder=$(mktemp -d)
        unzip -d $tmpzipfolder $tmpzip
        cp $tmpzipfolder/ttf/*.ttf $fonts_dir
        rm -r $tmpzipfolder
        msg success "  - Fonts installed"
        ls -la $fonts_dir
        fc-cache -f
    else
        msg error "Download falhou"
    fi
    rm $tmpzip

}

function install_alacritty {
    alacritty_version=$(alacritty --version)
    if [ "$?" == "0" ]; then
        msg success "Disponivel: $alacritty_version"
        return
    fi

    msg info "* ALACRITTY"
    msg info "  - Instalando dependências"

    sudo apt install -qq cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 curl tmux

    if [ cargo install alacritty ]; then
        mkdir -p $HOME/.config/alacritty
        config_file="$home/.config/alacritty/alacritty.toml"

        cat >$config_file <<-EOM
[font.normal]
family = "Fira Code Nerd Font Mono"
style = "Regular"

[[keyboard.bindings]]
action = "Paste"
key = "Paste"

[[keyboard.bindings]]
action = "Copy"
key = "Copy"

[[keyboard.bindings]]
action = "Paste"
key = "V"
mode = "~Vi"
mods = "Control|Shift"

[[keyboard.bindings]]
action = "Copy"
key = "C"
mods = "Control|Shift"

[[keyboard.bindings]]
action = "Copy"
key = "Insert"
mods = "Control"

[[keyboard.bindings]]
action = "PasteSelection"
key = "Insert"
mods = "Shift"

[shell]
args = ["-l", "-c", "tmux attach || tmux"]
program = "/bin/bash"
EOM
        msg success "Instalação do alacritty com sucesso: $config_file"
    else
        msg error "Instalação do alacritty não concluiu com sucesso! Verifique!"
        exit 1
    fi
}

function install_starship {
    starship_version=$(starship --version | grep starship)
    if [ "$?" == "0" ]; then
        msg success "Disponível: $starship_version"
        return
    fi

    msg info "* STARSHIP"
    curl -sS https://starship.rs/install.sh | sh

    if [ $? == 0 ]; then
        if [ grep starship $HOME/.bashrc ]; then
            msg info "  - Starship instalado e habilitado em .bashrc"
            return
        fi
        echo 'eval "$(starship init bash)"' >>$HOME/.bashrc
        msg success "  - Starship instalado e habilitado em .bashrc"

        msg info "  - Adicionando configuração"

        mkdir -p ~/.config && touch ~/.config/starship.toml
        msg warn "Feche este terminal e execute o comando novamente para que o PATH esteja atualizado"
    else
        msg error "Instalação do starship não concluiu com sucesso! Verifique!"
    fi
    exit 1
}

function install_tmux {
    config_file="${HOME}/.tmux.conf"
    cat >$config_file <<-EOM
set-option -sa terminal-overrides ",xterm*:Tc"
setw -g mode-keys vi

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

set -g @plugin 'catppuccin/tmux'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOM
}

function install_email {
    mail_prompt_rc=$(grep "mail_prompt()" "$HOME/.bashrc")
    if [ $? -eq 0 ]; then
        msg success "Email prompt installed"
        return
    fi
    cat >>"$HOME/.bashrc" <<EndOfText
# MAIL PROMPT

MAIL_CHECK_TIME=0
mail_prompt() {
    local pwd='~'
    local MAIL_SECONDS_DIFF=$MAILCHECK

    local MAIL_ELAPSED_SECONDS=$((SECONDS - MAIL_CHECK_TIME))

    [ "$PWD" != "$HOME" ] && pwd=${PWD/#$HOME\//\~\/}

    printf "\033]0;%s@%s:%s\033\\%s" "${USER}" "${HOSTNAME%%.*}" "${pwd}"

    if [[ "$MAIL_CHECK_TIME" -eq "0" || "$MAIL_ELAPSED_SECONDS" -gt "$MAIL_SECONDS_DIFF" ]]; then
        local MAILX="$(mailx 2>/dev/null &)"
        UNREADEN_REGEX="\s([0-9]{1,4})\sn"
        [[ $MAILX =~ $UNREADEN_REGEX ]] && UNREADEN=$(echo "${BASH_REMATCH[1]}") || UNREADEN=0
        local COUNT=$((UNREADEN))
        local MESSAGE_TEXT="message"
        if [ "$COUNT" -gt "0" ]; then
            if [ "$COUNT" -gt "1" ]; then
                MESSAGE_TEXT="messages"
            fi
            echo "$COUNT unreaden $MESSAGE_TEXT. Run mutt"
        fi
        MAIL_CHECK_TIME=$SECONDS
    fi

}

if [[ $(which mailx) ]]; then
    PROMPT_COMMAND="mail_prompt"
fi
EndOfText
    sudo apt install mailtools postfix mutt
    sudo adduser $USER mail
    msg success "Installed mail prompt"
}

msg success "*** TERMINAL SETUP ***"
# check_sudo

install_firacode_font

install_rust

install_alacritty

install_starship

install_email