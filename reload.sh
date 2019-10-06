#!/bin/bash

inotifywait -q -m -e close_write * |
while read -r filename event; do
  echo Compiling new file...
  rm tp1_if_asm
  make tp1_if_asm       # or "./$filename"
  echo Ready.
done