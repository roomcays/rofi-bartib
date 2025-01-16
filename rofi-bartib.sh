#!/usr/bin/env bash

if [ "$1" == "show" ]; then
	if [ -z "$2" ]; then
	    rofi -e "No time-tracker file passed"
	    exit 1
	fi
    rofi -show "Time tracker" -modes "Time tracker:$0 $2" -kb-custom-1 'Alt+s' -kb-custom-2 'Alt+c'
    exit 0
fi

BARTIB="bartib -f $1"

if [ "$ROFI_RETV" == 10 ]; then
    $BARTIB stop &> /dev/null
    exit 0
fi

if [ "$ROFI_RETV" == 11 ]; then
    $BARTIB cancel &> /dev/null
    exit 0
fi

if [ -n "$ROFI_INFO" ]; then
    $BARTIB continue $ROFI_INFO &> /dev/null
    exit 0
fi

echo -en "\0markup-rows\x1ftrue\n"
echo -en "\0use-hot-keys\x1ftrue\n"
echo -en "\0prompt\x1fStart activity\n"
CURRENT=$($BARTIB current | tail --lines=-2 | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2} //' | awk '{$NF=""}1' | sed 's/ $//')
if [ "$CURRENT" == "No Activity is currently" ]; then
    echo -en "\0message\x1f<span weight='light' size='small'>No activity is currently running</span>\n"
else
    echo -en "\0message\x1f<span weight='bold' size='small'>$CURRENT</span> | <span weight='light' size='small'>[ALT+s] to stop [ALT+c] to cancel </span>\n"
fi

LAST=$($BARTIB last | grep '^\[' | sort | sed -E 's/^\[([0-9]+)\] (.*)/\2\\0info\\x1f\1/')

echo -en "$LAST"
