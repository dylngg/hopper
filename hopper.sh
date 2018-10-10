#!/bin/bash
# Hopper: A simple script to simplify rsyncing files between n>1 computers

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  cat <<EOF
usage: hopper.sh <source> <user@hop1> ... <user@hopN> <user@dest:target_path>
   or  hopper.sh <user@source:source_path> <user@hop1> ... <user@hopN> 
   or  hopper.sh <user@source:source_path> <user@hop1> -i <path_to_ssh_key>
                 ... <user@hopN> <user@dest:target_path>
   or  hopper.sh <rsync_options> <user@source:source_path> <user@hop1> ... <user@hopN> 
   or  hopper.sh <source> <user@hop1@hop2@dest:target_path>
   or  hopper.sh <source> <user@hop1@hop2@hopN> <user@dest:target_path>

A simple script that simpifies the rsyncing of files between n>1 computers. 
NOTE: -av is automatically invoked when rsyncing.

optional arguments:
    -i <path_to_ssh_key>  A optional ssh key for the computer to the left of
                          the argument.              

rsync_options:
    Any options passed in here are passed into rsync.

examples:
    The following example is a basic example for hopping one 
    hopper.sh ~/sourcedir user@hop user@dest:~/target
EOF
  exit 0

# # if args
elif [ $# -ge 2 ]; then

  # check for rsync args
  RSYNC_ARGS=()
  while (( "$#" )); do
    if [[ "$1" == -* ]]; then
      RSYNC_ARGS+=("$1")
      shift
    else
      break
    fi
  done

  # get the source directory
  SOURCE="$1"
  shift

  PREV=""
  MID_ARGS=()
  TARGET=""
  while (( "$#" )); do

    # if it's a ssh location
    if [[ "$1" == *@* ]]; then
      MID_USER="`echo $1 | cut -d@ -f1`"
      # iterate through each @ symbol to catch special user@hop@hop syntax
      IFS='@' read -ra HOP <<< "${1#*@}"
      for i in "${HOP[@]}"; do

        # if it has a source
        if [[ "$i" == *:* ]]; then
          TARGET="$MID_USER@$i"
          break
        fi

        # otherwise, add a ssh command
        MID_ARGS+=("-e ssh -o 'ProxyCommand ssh -A $MID_USER@$i nc %h %p' ")
        PREV="-e \'ssh -o \"ProxyCommand ssh -A $MID_USER@$i nc %h %p\"\'"
      done

    # if they specified a key
    elif [ "$1" == "-i" ] && [ "$PREV" != "" ] && [ "$2" != "" ]; then
      MID_ARGS+=("-i $2")
      shift
    else
      echo "Invalid Destination Args. Exiting."
      exit 1
    fi

    shift
  done
  rsync ${RSYNC_ARGS[@]} -azv "${MID_ARGS[@]}" $SOURCE $TARGET
fi