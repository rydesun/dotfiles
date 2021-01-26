#!/bin/zsh -e

if command -v antibody &>/dev/null; then
	echo Updating plugins...
	antibody update
else
	echo antibody is missing >&2
fi

echo
echo Done.
