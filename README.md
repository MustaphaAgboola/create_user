# create_user
This article is the documentation of HNG stage one task, HNG internship is fast-pacedbootcamp for learning digital skills. You can find out more at there  [website.](https://hng.tech/internship) There's also [HNG Premium Network](https://hng.tech/premium) which connects top techies and allow them to grow their career and collaborate with otheers.


This is a step-by-step breakdown of the task

## Step 1. 
The first line is shebang line which tells the OS this is a shell script. I'm using `#!/bin/sh` instead of `#!/bin/bash` so that it can be executed on both new and older version of the OS

## Step 2
Assigning first argument to a variable `file="$1"`

## Step 3 
Create a conditional statement to check if the arguement is a file that exist
`if [[ ! -f $file ]]; then
  echo "File not found!"
  exit 1
fi`

## Step 3
Create a loop that read file and split the content then assign them to variable "username" and "groups" `while IFS=";" read -r username groups; do`

## Step 4 
Removes whitespaces in variables `username=$(echo "$username" | tr -d '[:space:]')
                                  groups=$(echo "$groups" | tr -d '[:space:]')`

## Step 5
Split the variable 'groups' by using  ',' and assign its value to 'groups_array' in order to make list `IFS=',' read -ra groups_array <<< "$groups"`

## Step 6
Create a loop that run through the list of values in the variable 'groups_array' and check if a group exist in the OS that has the same name as the values, if not, then create group. ` for group in "${groups_array[@]}"; do  
        if ! grep -q "^$group:" /etc/group; then
            sudo groupadd "$group"
            echo "Created group: $group"
        fi
    done`

## Step 7
Checks if user does not exist, then create user and assign groups. Also making sure that user is assigned to their primary group. `if ! grep -q "^$username:" /etc/passwd; then
                sudo useradd -m -s /bin/bash -G "$groups"
                sudo usermod -aG "$username" "$username"
        else echo "user already exist"
        exit 1 
        fi`

## Step 8
Generate a 12 character random password and assign it to variable 'password'
`password=$(openssl rand -base64 12)`

## Step 9
Set auto-geerated password for user `echo "$username:$password" | sudo chpasswd`

## Step 10
Change ownership and grant them write access to be able to create or modify files in the '/var/log/' directory and then log 'date', 'username' and 'groups' of newly created user in order to keep record. `  sudo chown ubuntu /var/log
                            sudo chmod u+w /var/log
                            echo "$(date) - User $username created with $groups" >> /var/log/user_management.log`

## Step 11
Change ownership and grant them write access in order to create or modify files in '/var/secure/' and then securely store users password and username.
` sudo chown ubuntu /var/secure
  sudo chmod u+w /var/secure
  echo "$username:$password" >> /var/secure/user_passwords.csv`

## Step 12
Set permission and ownership for user home directory,to ensure that only the owner has access and control over their home directory and group member and other user cannot access it. `sudo chmod 700 "/home/$username"
            sudo chown -R "$username:$username" "/home/$username"`