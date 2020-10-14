#!/bin/bash
function add2FA() {
    task "copying keyboard"
    sudo cp "${WORKDIR}/files/keyboard" /etc/default
}
