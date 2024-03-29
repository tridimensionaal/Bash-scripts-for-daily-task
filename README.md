# Bash scripts for daily tasks
---
### Contents:
  - [Description](#Description)
  - [Scripts](#Scripts)
      - [touch-f](#touch-f)
      - [mv-lst-d](#mv-last-d)
      - [files](#files)
      - [snd-lst-p](#snd-lst-p)
      - [rename-f-d](#rename-f-d)
      - [shellcheck-all](#shellcheck-all)
      - [wifi](#wifi)
      - [init-tmux](#init-tmux)
  
## Description
- **Bash scripts for daily tasks** is a list of shell scripts to automate simple tasks of the daily routine.

### Scripts
- #### touch-f
  - **Description**: Creates a files in the current directory and depending on their extesion (.py, .js, .sh, .c or .cpp) adds some functionalities.
  - **How to use**: 
    ```bash
       ./touch-f file-name.extension
    ```
- #### mv-lst-d
  - **Description**: Move the last file added to the *~/Downloads* directory to the actual directory.
  - **How to use**: 
    ```bash
       ./mv-lst-d
    ```
- #### files
  - **Description**: Scans all the files of the current directory and for each one performs some actions (open the file, see the content of the fie or delete the file) depending of your choice.
  - **How to use**: 
    ```bash
      ./files
    ```
- #### snd-lst-p
  - **Description**: Sends via email the last file added to the *~/Pictures* directory.
  - **How to use**: 
    ```bash
      ./snd-lst-p mail.to.send@file.com
    ```
  - **Considerations**: The script uses `mutt`. The following [page](https://www.garron.me/en/go2linux/send-mail-gmail-mutt.html) explains how to install and configure mutt with gmail.

- #### rename-f-d
  - **Description**: Rename the file to the name of the current directory, keeping the file extension.
  - **How to use**: 
    ```bash
      ./rename-f-d file-to-be-renamed.extesion 
    ```

- #### shellcheck-all
  - **Description**: Applies the command `shellcheck` to all files in the current directory and adds a comment to each file that contain the command (shellcheck) output for that file.
  - **How to use**: 
    ```bash
      ./shellcheck-all 
    ```
  - **Considerations**: The script uses `shellcheck`. 

- #### mk-todo-md
  - **Description**: Creates a TODO.md in the current directory. A TODO.md file is a markdown file that contains a list of things to do.
  - **How to use**: 
    ```bash
      ./mk-todo-md 
    ```

- #### wifi
  - **Description**: Turns off wifi if connected, otherwise turn it on.
  - **How to use**: 
    ```bash
      ./wifi
    ```
  - **Considerations**: The script uses `nmcli`. 

- #### init-tmux
  - **Description**: Creates a new tmux session, adds windows to it and starts the session.
  - **How to use**: 
    ```bash
      ./init-tmux
    ```
  - **Considerations**: The script uses `tmux`. 
