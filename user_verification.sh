Testing from AWS Instance
#!/bin/bash
#
echo -e "*******************************************************************************************************"
echo -e "** This Script is Private Property Of T-Systems INDIA,Copy Right is strictly prohibited.             **"
echo -e "**    Script Usage:-  This Script is used for checking the User login access                         **"
echo -e "**                    Here is the script Option:-                                                    **"
echo -e "**     1 - Checking Network connectivity,sshd service & Uptime                                       **"
echo -e "**         -----> The above option includes checking both Network and SSH Service of Remote client   **"
echo -e "**     2 - User Status                                                                               **"
echo -e "**         -----> The above option includes checking Account Lock, password expire,                  **"
echo -e "**         Valid login shell, SSHD_Config Access and Blank Password.                                 **"
echo -e "**     3 - User Group Information                                                                    **"
echo -e "**         -----> The above option is to check the affected accoout/user Privilege                   **"
echo -e "**     Author Mahendra K                                                                             **"
echo -e "\e[31m********************************************************************************************************\e[0m"
Userid=`/usr/bin/whoami`
{
if [[ $Userid == root ]]
  then echo -e "\e[32mWelcome Root,Explore the Option Of User Managment\e[0m"
  sleep 3
  else echo -e "\e[35mPlease run as root/admin privilage\e[0m" && exit 0
fi
}
function ping
{
echo -e "\e[31mEnter Server Name:\e[0m"
read selection
SSH=`nmap --system-dns -p22 $selection | egrep -w "open|closed"| awk '{print $2}'`
/usr/bin/ping -c 3 $selection > /tmp/ping.out
Result=`echo $?`
if [[ $Result == 0 ]]
 then
 echo -e "\e[32mServer is reachable through ping\e[0m"
 sleep 3
if [[ $SSH == open ]]
 then
 echo "ssh port 22 is Listening as expected"
 sleep 3
 else
 echo "ssh port 22 is not Listening, please check ssd service status from console"
 sleep 3
fi
 else
 echo -e "\e[35mServer not reachable Further Troubleshooting required\e[0m"
 sleep 3
 fi
   }
function userstatus
{
echo -e "\e[31mEnter User/Userid Name:\e[0m"
read selection
id $selection 1>>/dev/null
Result=`echo $?`
if [[ $Result == 0 ]]
 then
 echo -e "\e[32mUser exist checking for Account lock and Blank password\e[0m"     	
 LockResult=`pam_tally2 --user=$selection | awk '{print $2}'|grep -o -E '[0-9]+'`       ==================================>>>this doesn't actually say if account is locked
 BlankPasswd=`awk -F":" '($2 == "!" || $2 == "*") {print $1}' /etc/shadow | grep $selection`   ===========================>>>spelling - passwedExpire
 PasswedExpire=`/usr/bin/chage -l $selection | grep "Password expires"| cut -d ":" -f 2| awk '{print $4}'`  ==============>>>why "print $4" to awk ?
 Shells1=`cat /etc/passwd | grep -w $selection | cut -d ":" -f 7`
 Shells2=`cat /etc/shells | grep $Shells1`
 SystemShells=`echo $?`
else
 echo -e "\e[35mUser doen't exist\e[0m" && exit 0
 sleep 3
fi
if [[ $SystemShells == 0 ]]
then
echo -e "\e[32mUser having valid shells\e[0m"
sleep 3
SSH_ACCESS=`cat /etc/ssh/sshd_config | egrep -i "AllowUsers|DenyUsers|AllowGroups"| awk '{print $2}'`
if [[ $selection == $SSH_ACCESS ]]								===========================>>>sshd_config wont have the user information
then
echo -e "\e[32mUser part of SSH ACCESS\e[0m"
sleep 3
else
echo -e "\e[35mUser not part of SSH Access, check entry exist in sshd_config file\e[0m"
sleep 3
fi
else
echo -e "\e[35mUser not holding valid login shell , current shell is $Shells1\e[0m"
sleep 3
fi
if [[ $BlankPasswd == $selection ]]
  then
  echo -e "\e[35mUser having blank password , check with user before setting the password\e[0m"
  sleep 3
  else
  echo -e "\e[32mUser having valid  password\e[0m"
  sleep 3
fi
if [[ $LockResult == 0 ]]
 then
 echo -e "\e[32mUser Account is Not Locked\e[0m"
 sleep 3
if [[ $PasswdExpire == changed ]]   =====================================================================>>> PasswdExpire varial has a date value and not a string as"changed"
 then
 echo -e "\e[35mUser password expired and required reset,do you want to continues:\e[0mYes or No"
 read Option
if [[ $Option == Yes ]]
 then echo "Sample123" | passwd --stdin $selection
 /usr/bin/passwd -e $selection
 echo -e "\e[32mPassword Reset Completed,please share the new password with Requested secured way\e[0m"
 sleep 3
 else
 echo -e "\e[35mPassword Reset request denied by Requestor\e[0m"
 sleep 3
fi
 else
 echo -e "\e[32mPassword not expired\e[0m"
 sleep 3
fi
 else
 echo "unlocking the Account `pam_tally2 --user=$selection --reset`"
 sleep 3
fi
 }
function usergroup
{
echo "Enter User/Userid Name:"
read selection
id $selection 1>>/dev/null
Result=`echo $?`
if [[ $Result == 0 ]]
 then
 echo -e "\e[32mUser exist checking for Admin or Normal User Privilage"
 sleep 3
else
 echo -e "\e[35mUser doen't exist\e[0m" && exit 0
 sleep 3
fi
File1=`ls -l /etc/sudoers`
Result1=`echo $?`
File2=`ls -l /etc/sudoers.d/sudoers 2>/dev/null`
Result2=`echo $?`
if [ $Result1 == 0 ]
then `cat /etc/sudoers 2>/dev/null| grep -v ^#|grep -v Defaults|grep "ALL"|awk '{print $1}'|sed 's/%//'>/tmp/sudo1.txt`
Admin=`groups $selection | awk -F ":" '{print $2}' | xargs -n1 | grep -v $selection | while read a; do grep "$a" /tmp/sudo1.txt ; done|wc -l`
elif [ $Result2 == 0 ]
then `cat /etc/sudoers.d/sudoers 2>/dev/null| grep -v ^#|grep -v Defaults|grep "ALL"|awk '{print $1}'|sed 's/%//'1&2>/tmp/sudo2.txt`
Admin=`groups $selection | awk -F ":" '{print $2}' | xargs -n1 | grep -v $selection | while read a; do grep "$a" /tmp/sudo2.txt ; done|wc -l`
fi
if [[ $Admin -ne 0  ]]
 then
 echo -e "\e[32mUser Having Admin Access\e[0m"
 sleep 3
 else
 echo -e "\e[32mUser is normal\e[0m"
 sleep 3
 fi
   }
function exit
{
break
}
while true
do
clear
echo
echo "Menu"
echo "---------------"
echo
echo "1 - Checking Network connectivity,sshd service"
echo "2 - User Status"
echo "3 - User Group Information"
echo "4 - Exit"
echo
echo "Enter Choice:"
read selection
echo
case $selection in
1) ping;;
2) userstatus;;
3) usergroup;;
4) exit

esac
done
