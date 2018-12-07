function userstatus
{
 echo -e "\e[35mEnter User/Userid Name:\e[0m"
 read selection
 id $selection 1>>/dev/null
 Result=`echo $?`
 if [[ $Result == 0 ]]
 then
  echo -e "\e[32mUser exist...Checking for Account lock and Blank password\e[0m"     	
  LockResult=`pam_tally2 --user=$selection | awk '{print $2}'|grep -o -E '[0-9]+'`      
  BlankPasswd=`awk -F":" '($2 == "!" || $2 == "*") {print $1}' /etc/shadow | grep $selection`  
  PasswdExpire=`/usr/bin/chage -l $selection | grep "Password expires"| awk -F ":" '{print $2}'` 
  Shells1=`cat /etc/passwd | grep -w $selection | cut -d ":" -f 7`
  Shells2=`cat /etc/shells | grep $Shells1`
  SystemShells=`echo $?`
 else
  echo -e "\e[31mUser doesn't exist\e[0m" && exit 0
  sleep 3
 fi
 if [[ $SystemShells == 0 ]]
 then
  echo -e "\e[32mUser has a valid shells\e[0m"
  sleep 3
 else
  echo -e "\e[31mUser not holding valid login shell , current shell is $Shells1\e[0m"
  sleep 3
 fi
 if [[ $BlankPasswd == $selection ]]
 then
  echo -e "\e[31mUser having blank password , check with user before setting the password\e[0m"
  sleep 3
 else
  echo -e "\e[32mUser having valid  password\e[0m"
  sleep 3
 fi
 cat /etc/ssh/sshd_config | egrep "^AllowUsers | ^AllowGroups" > /dev/null
 ssh_allow=$?
 cat /etc/ssh/sshd_config | egrep "^DenyUsers | ^DenyGroups" > /dev/null
 ssh_deny=$?
 if [[ $ssh_allow -eq 0 || $ssh_deny -eq 0 ]]
 then
  echo "sshd level restrictions in place for this system"
  sleep 2
  echo "Checking for this particular user"
  sleep 2
  cat /etc/ssh/sshd_config | egrep "^AllowUsers | ^AllowGroups" | grep aneesh1 > /dev/null
  user_ssh_allow=$?
  for i in `groups aneesh1 | awk -F ":" '{print $2}' | xargs -n 1`
  do
  cat /etc/ssh/sshd_config | grep "^AllowGroups" | grep $i > /dev/null
  done
  group_ssh_allow=$?
  cat /etc/ssh/sshd_config | egrep "^DenyUsers | ^DenyGroups" | grep aneesh1 > /dev/null
  user_ssh_deny=$?
  for i in `groups aneesh1 | awk -F ":" '{print $2}' | xargs -n 1`
  do
  cat /etc/ssh/sshd_config | grep "^DenyGroups" | grep $i > /dev/null
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
 if [[ $LockResult == 0 ]]
 then
  echo -e "\e[32mUser Account is Not Locked\e[0m"
  sleep 3
 else
  echo "unlocking the Account `pam_tally2 --user=$selection --reset`"
  sleep 3
 fi
 if [[ $PasswdExpire == "password must be changed" ]]
 then
  echo -e "\e[31mUser password expired and required reset,do you want to continues:\e[0mYes or No"
  read Option
  if [[ $Option == Yes ]]
  then 
   echo "Sample123" | passwd --stdin $selection
   /usr/bin/passwd -e $selection
   echo -e "\e[32mPassword Reset Completed,please share the new password with Requested secured way\e[0m"
   sleep 3
  else
   echo -e "\e[31mPassword Reset request denied by Requester\e[0m"
   sleep 3
  fi
 else
   echo -e "\e[32mPassword not expired\e[0m"
   sleep 3
 fi
}
userstatus
