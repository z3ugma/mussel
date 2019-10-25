#!/bin/bash
source env.vista

trap 'echo ''; kill $(jobs -p)>/dev/null 2>&1 ; stty sane' INT

  mumps /fetdb/r/*.m
  mumps -run FTWEB &
  PID=$!

while inotifywait -e attrib /fetdb/r/*.m; do
  kill $PID
  mumps /fetdb/r/*.m
  mumps -run FTWEB &
  PID=$!
done