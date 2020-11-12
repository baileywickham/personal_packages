#!/bin/bash
function add2FA() {
    task "copying keyboard"
    sudo cp "${PPACKAGES}/files/keyboard" /etc/default
}
