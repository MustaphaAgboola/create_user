# HNG 11 Stage One Task Documentation
This article is the documentation of HNG stage one task, HNG internship is fast-pacedbootcamp for learning digital skills. You can find out more at there  [website.](https://hng.tech/internship) There's also [HNG Premium Network](https://hng.tech/premium) which connects top techies and allow them to grow their career and collaborate with otheers.

## Introduction

The `create_user` script automates the process of creating users and groups on a Unix-based system. This script reads user information from a specified file, creates groups if they don't exist, adds users to the system, and logs the actions taken. It also sets up user passwords and permissions securely.

## Challenges Faced
1. **Ensuring Compatibilty:**  Chosing a shebang line that works across different Unix system was important. I opted for `#!/bin/bash` to ensure compatibility with most Unix-based systems.

2. **Validating File Input:** Handling scenarios where the input file might not exist or formatted correctly requirred solid error handling.

3. **Group and User Management:** Creating groups and users, especially checking for their existence and handling updates appropriately, presented a challenge.

4. **Security Concerns:** Generating and securely storing user passwords, and setting appropriate permissions for user directories, were important for maintaining system security.

5. **Logging and Documentation:** Keeping a detailed log of actions taken by the script for future reference and troubleshooting was neccessary.



## Solutions Implemented

### Script Header
The script starts with a shebang line to specify the shell to use.
```sh
#!/bin/sh
```

### Step 1: Define the File to Read
Assign the first argument passed to the script to the file variable.
 ```sh
file="$1"
```

### Step 2: Check if the File Exists
Verify if the specified file exists. If not, print an error message and exit.
```sh
if [[ ! -f $file ]]; then
  echo "File not found!"
  exit 1
fi
```

### Step 3: Read the File Line by Line
Read the file line by line, splitting each line into username and groups, and trailing whitespaces.
``` sh
while IFS=";" read -r username groups; do
    username=$(echo "$username" | tr -d '[:space:]')
    groups=$(echo "$groups" | tr -d '[:space:]')
```

### Step 4: Check and Create Groups
Split the groups string into an array and create each group if it doesn't exist.

```sh
    IFS=',' read -ra groups_array <<< "$groups"
    for group in "${groups_array[@]}"; do
        if ! grep -q "^$group:" /etc/group; then
            sudo groupadd "$group"
            echo "Created group: $group"
        fi
    done
```



### Step 5: Check and Create User
Check if the user exists. If not, create the user and add them to the specified groups. If the user exists, update their group memberships.
``` sh
    if ! grep -q "^$username:" /etc/passwd; then
        sudo useradd -m -s /bin/bash -G "$groups" "$username"
        sudo usermod -aG "$username" "$username"
    else
        echo "User already exists"
        sudo usermod -aG "$username" "$username"
        sudo usermod -aG "$group" "$username"
    fi
```

### Step 6: Generate and Set User Password
Generate a 12-character random password and set it for the user.
```sh
    password=$(openssl rand -base64 12)
    echo "$username:$password" | sudo chpasswd
```


### Step 7: Log Actions
Log the actions taken in the `/var/log/user_management.log file`.
```sh
    user=$(whoami)
    sudo chown $user /var/log
    sudo chmod o+w /var/log
    echo "$(date) - User $username created with $groups" >> /var/log/user_management.log
```


### Step 8: Securely Store Passwords
Ensure the `/var/secure/` directory exists, then store the username and password securely in a file.
``` sh
        if [ ! -d /var/secure/ ]; then
        sudo mkdir -p /var/secure
    fi
    sudo chown $user /var/secure
    sudo chmod u+w /var/secure
    echo "$username:$password" >> /var/secure/user_passwords.csv
```

### Step 9: Set Home Directory Permissions
Set the correct permissions for the user's home directory to ensure privacy.
```sh
    sudo chmod 700 "/home/$username"
    sudo chown -R "$username:$username" "/home/$username"
    echo "$username:$groups"
done < "$file"
```
## Lessons Learned
1. **Error Handling:** Implementing solid error handling is crucial for scripts that manage system resources.

2. **Security Best Practices:** Ensuring that user passwords are securely generated and stored, and setting proper file permissions, is vital for maintaining system security.

3. **Modular Scripting:** Breaking down the script into clear, manageable steps helps in debugging and maintenace.

4. **Logging:** Keeping a detailed log of script actions aids in troubleshooting and auditing. 

## Usage

### Prerequisites
To run this scripts on an Ubuntu system, you need to have following:
1. **Git:** ensure Git is installed on your system. If not, install Git using:
```
sudo apt-get install git
```

2. **OpenSSL:** Make sure OpenSSL is installed for password generation:
```
sudo apt-get install openssl
```

3. **Sudo Privileges:** The script requires sudo privileges to create users and groups.

### Steps to Use the Script
To use the `create_user.sh` script, follow these steps:
1. **Clone repository:** Clone the repository from the Github repository:
```
git clone https://github.com/MustaphaAgboola/create_user
cd create_user
```
2. **Prepare the input file:** Create a text file containing the usernames and groups.

Example: 
```
light; sudo,dev,www-data
idimma; sudo
mayowa; dev,www-data
```

3. **Run the Script:** Execute the script from the terminal, passing the input file as an argument.

```
bash create_user file_name.txt
```

Make sure the script has executable permissions. If not, you can add the executable permission using:
```
chmod +x create_user
```


## Conclusion
This script efficiently automates the process of user and group management, ensuring security and proper logging of actions. By using this script, system administrators can save time and reduce the risk of errors in user management tasks.

