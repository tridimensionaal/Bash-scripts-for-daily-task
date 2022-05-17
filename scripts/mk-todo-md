#!/bin/bash

content="
# Example of TODO.md

List of things to do in the current project.

### Todo

- [ ] First task todo 
- [ ] Second task todo 
  - [ ] Sub-task or description  

### In Progress

- [ ] Working in the current task

### Done ✓

- [x] Create my first TODO.md
"

printf "$content" > TODO.md
# start shellcheck-all
# 
# In mk-todo-md.sh line 23:
# printf "$content" > TODO.md
#        ^--------^ SC2059: Don't use variables in the printf format string. Use printf "..%s.." "$foo".
# 
# For more information:
#   https://www.shellcheck.net/wiki/SC2059 -- Don't use variables in the printf...
