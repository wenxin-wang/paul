#!/bin/bash

if [ $# -eq 0 ]; then
	echo "usage: $0 orgfile"
	exit 1
fi

file=$1

# Nothing!
if [ ! -f $file ]; then
    exit 0
fi


if [ -f ~/.paul.sh ]; then
    . ~/.paul.sh
elif [ -f ~/.config/paul/config.sh ]; then
    . ~/.config/paul/config.sh
fi

# FROM: $sender
# TO: $recvname+keyword@$recvdomain
declare recvname recvdomain sender
declare -a KEYWORDS
MSMTP_OPTS=${MSMTP_OPTS:-""}
TMP=${TMP:-/tmp}

file=$(realpath $file)

tmpdir=$TMP/paul-org-imap-$$
mkdir -p $tmpdir

cd $tmpdir
ret=$(csplit $file '/^* /' '{*}')
cd - &>/dev/null

# Nothing!
if [ z"$ret" = z ]; then
    exit 0
fi

changed=0
for todo in $tmpdir/xx*; do
    subject=$(head -n1 $todo)
    if [[ z"$subject" != z'*'* ]]; then
	continue
    fi
    subject=${subject#'* '}

    kw=$(awk '{ print $1 }' <<<"$subject")
    keyword=""
    for k in "${KEYWORDS[@]}"; do
	if [ z"$k" = z"$kw" ]; then
	    keyword=$kw
	    subject=$(sed -e 's/^'"$kw"'\s*//' -e 's/\s*$//' <<<"$subject")
	    break
	fi
    done

    (
	cat <<EOF
To: $recvname+$keyword@$recvdomain
From: $sender
Subject: $subject

EOF
	tail -n +2 $todo
    ) | msmtp $MSMTP_OPTS "$recvname+$keyword@$recvdomain" && rm $todo

    changed=1
done

if [ z"$REPLACE" = z1 ] && [ z"$changed" = z1 ]; then
    cat $tmpdir/xx* >$file.tmp
    mv $file.tmp $file
fi

rm -rf $tmpdir
