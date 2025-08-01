# SSH-Key_from_AD
How to manage SSH-Keys from an Active Directory.

Prerequisites:
The connection to the realm must be made before this.

INSTRUCTIONS
1. Create a user in ActiveDirectory and give it permission to join PCs and make queries to the Domain.

2. Put the ad_validation.sh file somewhere inside the server, could be inside the /etc/ssh directory.
**ad_validation.sh**

3. Modify the ad_validation.sh file and add the parameters to complain your domain info.

4. Add the password of the user created before inside the file ldap_bind_pw

5. Modify the permissions of the files:

|$chmod 511 ad_validation.sh
|-
|$chmod 600 /etc/ssh/ldap_bind_pw

6. Add the next lines to the SSHD configuration:

|AuthorizedKeysCommand /path/to/ad_validation.sh
|-
|AuthorizedKeysCommandUser root
|PasswordAuthentication no
|PubkeyAuthentication yes

7. Finally, using the Users and Group manager from Active Directory, add the line SSHKey: rsa-key yourkeygeneratedasf3g13r23r in the altSecurityIdentities of the  attributes of the user.
