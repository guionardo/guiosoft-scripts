function get_tool() {
    tool_name=$1
    tool_apt=$2
    tool=$(eval which $tool_name)
    if [ $? != 0 ]; then
        echo "UNAVAILABLE TOOL '${tool_name}' RUN sudo apt install $tool_apt"
        return 1
    fi
    return 0
}

function get_jq() {
    jq=$(eval which jq)
    if [ $? != 0 ]; then
        echo "js não está disponível. Providencie a instalação (sudo apt install jq)"
        exit 1
    fi
}