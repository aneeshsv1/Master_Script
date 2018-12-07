cat /tmp/sshd_config | egrep "^AllowUsers | ^AllowGroups" > /dev/null
ssh_allow=$?
cat /tmp/sshd_config | egrep "^DenyUsers | ^DenyGroups" > /dev/null
ssh_deny=$?
if [[ $ssh_allow -eq 0 || $ssh_deny -eq 0 ]]
then
 echo "sshd level restrictions in place for this system"
 sleep 2
 echo "Checking for this particular user"
 sleep 2
 cat /tmp/sshd_config | egrep "^AllowUsers | ^AllowGroups" | grep aneesh1 > /dev/null
 user_ssh_allow=$?
 for i in `groups aneesh1 | awk -F ":" '{print $2}' | xargs -n 1`
 do
 cat /tmp/sshd_config | grep "^AllowGroups" | grep $i > /dev/null
 done
 group_ssh_allow=$?
 cat /tmp/sshd_config | egrep "^DenyUsers | ^DenyGroups" | grep aneesh1 > /dev/null
 user_ssh_deny=$?
 for i in `groups aneesh1 | awk -F ":" '{print $2}' | xargs -n 1`
 do
 cat /tmp/sshd_config | grep "^DenyGroups" | grep $i > /dev/null
 done
 group_ssh_deny=$?
else 
 echo "sshd level restrictions are not in place for this system"
 sleep 2
fi
if [[ $user_ssh_allow == 0 || $group_ssh_allow == 0 ]] && [[ $user_ssh_deny == 1 || $group_ssh_deny == 1 ]]
then
 echo "User is allowed ssh access"
else
 echo "user is denied ssh access"
fi
