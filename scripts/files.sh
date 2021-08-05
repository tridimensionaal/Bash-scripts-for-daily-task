#!/bin/bash

action(){
    case $2 in
        1)
            xdg-open $1
            echo 1
            ;;
        2)
            head $1
            echo 1
            ;;
        3)
            rm $1
            echo 0
            ;;
        4)
            echo 0
            ;;
        *)
            echo 1
            ;;
    esac
}

process_file(){
    bol=1
    while [ $bol -eq 1 ]
    do
        echo $(file $1)
        echo "What do yo want to do?"
        echo "- 1: Open file (xdg-open)"
        echo "- 2: View the content of the file (more)"
        echo "- 3: Remove the file"
        echo "- 4: End"

        read -p ">> "  option
        bol=$(action $1 $option)
    done
}

for file in *
do
    if [ -f $file ]
    then
        process_file $file
    fi 
done

