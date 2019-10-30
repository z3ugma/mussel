#!/bin/bash
source env.mussel

trap 'echo ''; kill $(jobs -p)>/dev/null 2>&1 ; stty sane' INT

  mumps /$mussel_dir/r/*.m
  mumps -run FTWEB &
  PID=$!

while inotifywait -e attrib /$mussel_dir/r/*.m; do
  kill $PID
  mumps /$mussel_dir/r/*.m
  mumps -run FTWEB &
  PID=$!
done
