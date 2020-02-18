#!/bin/bash
title=$1
filename=`date +%Y-%m-%d`-$title.md
# get going with templates
# https://stackoverflow.com/questions/3785320/how-to-use-a-template-in-vim
vim _posts/$filename
