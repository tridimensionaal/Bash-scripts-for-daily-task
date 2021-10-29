#!/bin/bash

read -rp "Search >> " search
printf "Results:\n" 
search=${search// /+}
res=$(curl -s https://www.youtube.com/results\?search_query\="$search" | \
    grep -o 'watch?v=[^"]*')

count=0
for line in $res
do
    if [ $count -eq 5 ]
    then
        break
    fi

    curl -s "https://www.youtube.com/$line" | \
        grep -o '<title>[^"]*</title>' | \
        sed -e 's/<title>//' -e 's/- YouTube<\/title>//'
    # printf "%s\n" $line
    count=$((count+1))
done
# start shellcheck-all
# 
# In srch-ytb.sh line 6:
# res=$(curl -s https://www.youtube.com/results\?search_query\="$search" | \
#                                                            ^-- SC1001: This \= will be a regular '=' in this context.
# 
# For more information:
#   https://www.shellcheck.net/wiki/SC1001 -- This \= will be a regular '=' in ...
