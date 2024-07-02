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

# Check if group exist, then create group
  IFS=',' read -ra group_array <<< "$groups"

  for group in "${groups_array[@]}"; do
        if ! grep -q "^$group:" /etc/group; then
                sudo groupadd "$group"
        fi
 done

# Check if user exist, then create group
        if ! grep -q "^$username:" /etc/passwd; then
                sudo useradd -m -s /bin/bash -G "$groups" "$username"
        else echo "user already exist"
        exit 1 
        fi
# Generate a 12-character random alphanumeric password
        password=$(openssl rand -base64 12)
        echo "Generated password: $password"

        # Set password for the user 
        echo "$username:$password" | sudo chpasswd
 # Log actions
         echo "$(date) - User $username created with $groups" >> /var/log/user_management.log
# Securely store passwords
         echo "$username:$password" >> /var/secure/user_passwords.csv

 # Set permission for home directory
         sudo chmod 700 "/home/$username"
          sudo chown -R "$username:$username" "/home/$username"


  echo "$username:$groups"
done < "$file"