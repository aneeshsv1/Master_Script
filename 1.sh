function userstatus
{
 sleep 1
 echo -n -e "\e[35mEnter User/User-id Name: \e[0m"
 read user
 id $user > /dev/null 2>&1
 Result=`echo $?`
 if [[ $Result == 0 ]]
 then
  sleep 1
  echo -e "\e[32mUser exists...Checking for Account lock and blank password\e[0m"
  sleep 1  
 else
  echo -e "\e[31mUser doesn't exist\e[0m" && exit 0
  sleep 1
 fi
 Shells1=`cat /etc/passwd | grep -w $user | cut -d ":" -f 7`
 Shells2=`cat /etc/shells | grep $Shells1`
 SystemShells=`echo $?`
 function CheckShadowLock
 {
  if [[ `cat /etc/shadow | grep -w $1 | cut -d ":" -f 2` == '!!'* ]]
  then return 99
  else
   if [[ `cat /etc/shadow | grep -w $1 | cut -d ":" -f 2` == '!'* ]]
   then return 98
   fi
  fi
 }
 CheckShadowLock $user
 PasswdExpiredShadow=`echo $?`
 BlankPasswd=`awk -F":" '($2 == "!!" || $2 == "*") {print $1}' /etc/shadow | grep $user`
 PasswdExpiredPam=`pam_tally2 --user=$user | awk '{print $2}'|grep -o -E '[0-9]+'`  
 PasswdExpiredChage=`/usr/bin/chage -l $user | grep "Password expires"| awk -F ":" '{print $2}'`
 if [[ $SystemShells == 0 ]]
 then
  echo -e "\e[32mUser has a valid shell\e[0m"
  sleep 1
 else
  echo -e "\e[31mUser not holding valid login shell, current shell is $Shells1\e[0m"
  sleep 1
 fi
 if [[ $BlankPasswd == $user ]]
 then
  echo -e "\e[31mUser having blank password , check with user before setting the password\e[0m"
  sleep 1
 else
  echo -e "\e[32mUser has a non-blank password\e[0m"
  sleep 1
 fi
 cat /etc/ssh/sshd_config | egrep "^AllowUsers | ^AllowGroups" > /dev/null
 ssh_allow=$?
 cat /etc/ssh/sshd_config | egrep "^DenyUsers | ^DenyGroups" > /dev/null
 ssh_deny=$?
 if [[ $ssh_allow -eq 0 || $ssh_deny -eq 0 ]]
 then
  echo -e "\e[31msshd level restrictions in place for this system\e[0m"
  sleep 1
  echo "Checking for this particular user"
  sleep 1
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
  if [[ $user_ssh_allow == 0 || $group_ssh_allow == 0 ]] && [[ $user_ssh_deny == 1 || $group_ssh_deny == 1 ]]
  then
   echo -e "\e[32User is allowed ssh access\e[0m"
  else
   echo -e "\e[31muser is denied ssh access\e[0m"
  fi
 else 
  echo -e "\e[32mSshd level restrictions are not in place for this system\e[0m"
 sleep 1
 fi 
 if [[ $PasswdExpiredPam == 0 ]]
 then
  echo -e "\e[32mUser Account is not Locked at pam\e[0m"
  sleep 1
 else
  echo -e "\e[35mUser Account is locked at pam and required reset,do you want to continues:\e[0mYes or No\e[0m"
  sleep 1
  read Option
  if [[ $Option == Yes ]]
  then
   echo -e "\e[35munlocking the Account\e[0m"
  pam_tally2 --user=$user --reset > /dev/null 2>&1
  else
   echo -e "\e[31mPassword Reset request denied by Requester\e[0m"
   sleep 1
  fi
 fi
 if [[ $PasswdExpiredChage == "password must be changed" ]]
 then
  echo -e "\e[31mUser password expired due to aging and required reset,do you want to continues:\e[0mYes or No\e[0m"
  sleep 1
  read Option
  if [[ $Option == Yes ]]
  then 
   echo "Sample123" | passwd --stdin $user > /dev/null 2>&1
   /usr/bin/passwd -e $user > /dev/null 2>&1
   echo -e "\e[32mPassword Reset Completed,please share the new password as "Sample123" with requested secured way\e[0m"
   sleep 1
  else
   echo -e "\e[31mPassword Reset request denied by Requester\e[0m"
   sleep 1
  fi
 else
  echo -e "\e[32mUser Account is not locked due to aging\e[0m"
  sleep 1
 fi
 if [[ PasswdExpiredShadow -eq 99 ]]
 then
  echo -n -e "\e[31mUser password is locked at system files and required reset,do you want to continues - \e[0mYes or No : \e[0m"
  read Option
  if [[ $Option == [Y,y]es ]]
  then
   echo -e "\e[35munlocking the Password\e[0m"
   sleep 1
   passwd -u $user > /dev/null 2>&1
  else
   echo -e "\e[31mPassword Reset request denied by Requester\e[0m"
   sleep 1
  fi
 else
 echo -e "\e[32mUser Password is not locked due to system files\e[0m"
 sleep 1
 fi
 if [[ PasswdExpiredShadow -eq 98 ]]
 then
  echo -e "\e[35mUser Account is locked at shadow file and required reset,do you want to continues - \e[0mYes or No : \e[0m"
  read Option
  if [[ $Option == Yes ]]
  then
   echo -e "\e[35munlocking the Account\e[0m"
   sleep 1
   usermod -U $user > /dev/null 2>&1
  else
   echo -e "\e[31mAccount Reset request denied by Requester\e[0m"
   sleep 1
  fi
 else
  echo -e "\e[32mUser Account is not locked due to system files\e[0m"
  sleep 1
 fi
} 
userstatus