# Arch Linux
alias pmq='pacman -Qs'
alias pms='pacman -Ss'
pmi() { pacman -Qi $1 2>/dev/null || pacman -Sii $1 }
pmo() { pacman -Qoq $1 2>/dev/null || pkgfile -i $1 }
pml() { (pacman -Qlq $1 2>/dev/null || pkgfile -lq $1) | sed '/\/$/d' }
pmb() { (pacman -Qlq $1 2>/dev/null || pkgfile -lq $1) | awk -F/ '/\/usr\/bin\/.+[^/]$/{print $NF}' }
pmd() { (pacman -Qlq $1 2>/dev/null || pkgfile -lq $1) | grep -e '\.service$' -e '\.socket$' }
