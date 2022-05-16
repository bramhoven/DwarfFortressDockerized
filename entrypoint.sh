#!/bin/bash

su df -c 'tmux new -d -s df "LD_PRELOAD=/lib/i386-linux-gnu/libz.so.1 /df_linux/df"'
/usr/sbin/sshd -D