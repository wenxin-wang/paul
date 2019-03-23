#!/data/data/com.termux/files/usr/bin/bash

export LD_PRELOAD=${PREFIX}/lib/libtermux-exec.so
fin () {
  termux-wake-unlock
  echo bye
}
trap fin EXIT
termux-wake-lock
REPLACE=1 /data/data/com.termux/files/usr/bin/bash ~/paul/org-imap.sh ~/storage/shared/orgzly/Inbox.org
