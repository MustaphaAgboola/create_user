#!/bin/bash

#  if the script is run with a filename arguement
 if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

# Read the input file line by line
while IFS=';' read -r username groups; do
    # Remove leading and trailing whitespaces
    username=$(echo "$username" | tr -d '[':space:']')
    groups=$(echo "$groups" | tr -d '[:space:]')

    # Create groups if they don't exist
    IFS=',' read -ra group_array <<< "$group"
    for group in "${group_array[@]}"; do 
        if ! grep -q "^$group:" /etc/group; then
            sudo groupadd "$group"
        fi
    done

    # Create user with specified groups
    sudo useradd -m -s /bin/bash -G "$group" "$username"

    # Set password for the user 
    echo "$username:$password" | sudo chpasswd

    # Log actions
    echo "$(date) - User $username created with $groups" >> /var/log/user_management.log

    # Securely store passwords
    echo "$username:$password" >> /var/secure/user_passwords.csv

    # Set permission for home directory
    sudo chmod 700 "/home/$username"
    sudo chown -R "$username:$username" "/home/$username"

done < "$1"
