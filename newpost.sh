#!/bin/bash
title=$1 

if [[ -z $title ]]; then
  echo "pass in a string for the title for this post"
  exit 1
fi

today=`date +%Y-%m-%d`
filename=${today}-${title}.md
template=$(cat <<EOF
---
layout: post
title:  "$(echo ${title} | tr "-" " ")"
date:  $(date '+%Y-%m-%d %H:%M:%S%z')
categories: me
---
EOF
)
echo "${template}" >> _posts/${filename}

 vim _posts/${filename}
