#!/bin/bash

# Define the file to read
file="$1"

# Check if the file exists
if [[ ! -f $file ]]; then
  echo "File not found!"
  exit 1
fi


# Read the file line by line
while IFS=";" read -r username groups; do
    # Remove leading and trailing whitespaces
    username=$(echo "$username" | tr -d '[:space:]')
    groups=$(echo "$groups" | tr -d '[:space:]')

    # Check if groups exist, then create groups
    IFS=',' read -ra groups_array <<< "$groups"  # Corrected variable name to groups_array

    for group in "${groups_array[@]}"; do  # Use singular 'group' here, not 'groups'
        if ! grep -q "^$group:" /etc/group; then
            sudo groupadd "$group"
            echo "Created group: $group"
        fi
    done

# Check if user exist, then create group
        if ! grep -q "^$username:" /etc/passwd; then
                sudo useradd -m -s /bin/bash -G "$groups" "$username"
                sudo usermod -aG "$username" "$username"
        else echo "user already exist"
        exit 1 
        fi
# Generate a 12-character random alphanumeric password

        password=$(openssl rand -base64 12)
        

        # Set password for the user 
        echo "$username:$password" | sudo chpasswd
 # Log actions
         sudo chmod o+w /var/log
         echo "$(date) - User $username created with $groups" >> /var/log/user_management.log
# Securely store passwords
         sudo chmod o+w /var/secure
         echo "$username:$password" >> /var/secure/user_passwords.csv

# Set permission for home directory

         sudo chmod 700 "/home/$username"
         sudo chown -R "$username:$username" "/home/$username"


         echo "$username:$groups"
done < "$file"