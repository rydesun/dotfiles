pkg-list-exclipit() {
    while read pkg; do
        apt show $pkg 2>/dev/null | grep "APT-Manual-Installed: yes" > /dev/null
        if [[ $? -eq 0 ]]; then echo $pkg; fi
    done <<(dpkg --get-selections | cut -f1)
}
