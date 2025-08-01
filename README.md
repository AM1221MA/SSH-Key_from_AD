# SSH-Key_from_AD
How to manage SSH-Keys from an Active Directory.

Prerequisites:
The connection to the realm must be made before this.

INSTRUCTIONS
FIRST
Create a user in ActiveDirectory and give it permission to join PCs and make queries to the Domain.

SECOND
Put the ad_validation.sh file somewhere inside the server, could be inside the /etc/ssh directory.
**ad_validation.sh**

THIRD
Modify the ad_validation.sh file and add the parameters to complain your domain info.

FOURTH
Add the password of the user created before inside the file ldap_bind_pw

FIFTH
Modify the permissions of the files:
$chmod 511 ad_validation.sh
$chmod 600 /etc/ssh/ldap_bind_pw

SIXTH
Add the next lines to the SSHD configuration:
|--------------------------------------------------
|AuthorizedKeysCommand /path/to/ad_validation.sh
|AuthorizedKeysCommandUser root
