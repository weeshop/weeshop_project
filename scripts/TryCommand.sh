#!/bin/bash

# https://blog.csdn.net/fjh1997/article/details/105702374/
function tryCommand() {
    while timeout -k 70 "${2:-10}" bash -c "${1}" ; [ $? != 0 ];
    do
      if [ $? = 124 ]; then
        echo "Timeout for ${2:-10} seconds, retry ..."
      else
        echo "Command fails, retry ..."
      fi
      sleep 1  # Pause before retry
    done
}
