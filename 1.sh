function userstatus
{
 sleep 1
 echo -n -e "\e[35mEnter User/User-id Name: \e[0m"
 read selection
 id $selection 1>>/dev/null
 Result=`echo $?`
 if [[ $Result == 0 ]]
 then
  sleep 2
  echo -e "\e[32mUser exists...Checking for Account lock and Blank password\e[0m"
  sleep 2  
  Shells1=`cat /etc/passwd | grep -w $selection | cut -d ":" -f 7`
  Shells2=`cat /etc/shells | grep $Shells1`
  SystemShells=`echo $?`
  function CheckShadowLock
  {
   if [[ `cat /etc/shadow | awk -F ":" '$1 == "$selection" {print $2}'` == '!!'* ]]
   then return 99
   else
    if [[ `cat /etc/shadow | awk -F ":" '$1 == "$selection" {print $2}'` == '!'* ]]
    then return 98
    fi
   fi
  }
  CheckShadowLock
  PasswdExpiredShadow=`echo $?`
  BlankPasswd=`awk -F":" '($2 == "!!" || $2 == "*") {print $1}' /etc/shadow | grep $selection`
  PasswdExpiredPam=`pam_tally2 --user=$selection | awk '{print $2}'|grep -o -E '[0-9]+'`  
  PasswdExpiredChage=`/usr/bin/chage -l $selection | grep "Password expires"| awk -F ":" '{print $2}'`
 else
  echo -e "\e[31mUser doesn't exist\e[0m" && exit 0
  sleep 2
 fi
 if [[ $SystemShells == 0 ]]
 then
  echo -e "\e[32mUser has a valid shell\e[0m"
  sleep 2
 else
  echo -e "\e[31mUser not holding valid login shell , current shell is $Shells1\e[0m"
  sleep 2
 fi
 if [[ $BlankPasswd == $selection ]]
 then
  echo -e "\e[31mUser having blank password , check with user before setting the password\e[0m"
  sleep 2
 else
  echo -e "\e[32mUser has a valid password\e[0m"
  sleep 2
 fi
 cat /etc/ssh/sshd_config | egrep "^AllowUsers | ^AllowGroups" > /dev/null
 ssh_allow=$?
 cat /etc/ssh/sshd_config | egrep "^DenyUsers | ^DenyGroups" > /dev/null
 ssh_deny=$?
 if [[ $ssh_allow -eq 0 || $ssh_deny -eq 0 ]]
 then
  echo -e "\e[31mSshd level restrictions in place for this system\e[0m"
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
  if [[ $user_ssh_allow == 0 || $group_ssh_allow == 0 ]] && [[ $user_ssh_deny == 1 || $group_ssh_deny == 1 ]]
  then
   echo -e "\e[32User is allowed ssh access\e[0m"
  else
   echo -e "\e[31muser is denied ssh access\e[0m"
  fi
 else 
  echo -e "\e[32mSshd level restrictions are not in place for this system\e[0m"
 sleep 2
 fi 
 if [[ $PasswdExpiredPam == 0 ]]
 then
  echo -e "\e[32mUser Account is not Locked at pam\e[0m"
  sleep 2
 else
  echo -e "\e[35mUser Account is locked at pam and required reset,do you want to continues:\e[0mYes or No\e[0m"
  read Option
  if [[ $Option == Yes ]]
   echo -e "\e[35munlocking the Account\e[0m"
  pam_tally2 --user=$selection --reset
  else
   echo -e "\e[31mPassword Reset request denied by Requester\e[0m"
   sleep 2
  fi
 fi
 if [[ $PasswdExpiredChage == "password must be changed" ]]
 then
  echo -e "\e[31mUser password expired at chage and required reset,do you want to continues:\e[0mYes or No\e[0m"
  read Option
  if [[ $Option == Yes ]]
  then 
   echo "Sample123" | passwd --stdin $selection
   /usr/bin/passwd -e $selection
   echo -e "\e[32mPassword Reset Completed,please share the new password as "Sample123" with requested secured way\e[0m"
   sleep 2
  else
   echo -e "\e[31mPassword Reset request denied by Requester\e[0m"
   sleep 2
  fi
  if [[ PasswdExpiredShadow -eq 99 ]]
  then
   echo -e "\e[35mUser password is locked at shadow and required reset,do you want to continues:\e[0mYes or No\e[0m"
   read Option
   if [[ $Option == Yes ]]
    echo -e "\e[35munlocking the Password\e[0m"
	passwd -u $selection
   fi
  elif [[ PasswdExpiredShadow -eq 98 ]]
  then
   echo -e "\e[35mUser Account is locked at shadow and required reset,do you want to continues:\e[0mYes or No\e[0m"
   read Option
   if [[ $Option == Yes ]]
    echo -e "\e[35munlocking the Account\e[0m"
	usermod -U $selection
   fi
 else
   echo -e "\e[32mPassword not expired\e[0m"
   sleep 2
 fi
}
userstatus
