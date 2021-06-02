#!/bin/zsh -ie

if command -v zinit &>/dev/null; then
	echo Updating plugins...
	zinit update --all --parallel
else
	echo zinit is missing >&2
fi

echo
echo Done.
