ui_echo() {
    echo "$@" >&"${STDOUT:-1}"
}

ui_cat() {
    cat "$@" >&"${STDOUT:-1}"
}

ui_read() {
    read "$@" 2>&"${STDERR:-2}" <&"${STDIN:-0}"
}
