#!/bin/bash

action(){
    read -p ">> " -n 1 option

    case $option in
        1)
            xdg-open $1
            return 1
            ;;
        2)
            more $1
            return 1
            ;;
        3)
            rm $1
            return 0
            ;;
        4)
            return 0
            ;;
        *)
            return 0
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
        bol=$(action $1)
    done
}

for file in *
do
    if [ -f $file ]
    then
        process_file $file
    fi 
done

