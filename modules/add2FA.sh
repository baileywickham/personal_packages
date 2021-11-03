#!/bin/bash
function add2FA() {
    task "copying keyboard"
    with_sudo cp "${PPACKAGES}/files/keyboard" /etc/default
}
