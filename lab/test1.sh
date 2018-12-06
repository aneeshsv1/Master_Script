#!/bin/bash
echo -e "*******************************************************************************************************"
echo -e "** This Script is Private Property Of T-Systems INDIA,Copy Right is strictly prohibited.             **"
echo -e "** Script Usage:-  This Script is used for checking the Server access and User login                 **"
echo -e "** Here are the script Options:-                                                                     **"
echo -e "**     1 - Server Status                                                                             **"
echo -e "**         -----> This option includes checking Network connectivity, SSH Service status and         **"
echo -e "**                uptime of the Remote client                                                        **"
echo -e "**     2 - User Status                                                                               **"
echo -e "**         -----> The above option includes checking Account Lock, password expire,                  **"
echo -e "**                validity of login shell and if a blank Password.                                   **"
echo -e "**     3 - Sudo access status i                                                                      **"
echo -e "**         -----> The above option is to check the affected accoout/user Privilege                   **"
echo -e "**     Author Aneesh S V                                                                             **"
echo -e "*******************************************************************************************************"
userid=`/usr/bin/whoami`
if [ $userid == root ]
then
 echo -e "\e[32mWelcome Root,Explore the Option Of User Managment\e[0m"
sleep 3
else
 echo -e "\e[35mPlease run as root/admin privilage\e[0m" && exit 0
fi
function ping
{
 echo -e "\e[35mEnter Server Name:\e[0m"
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
  echo -e "\e[32mssh port 22 is Listening as expected\e[0m"
  sleep 3
 else
  echo -e "\e[31mssh port 22 is not Listening, please check ssd service status from console\e[0m"
  sleep 3
 fi
 else
  echo -e "\e[31mServer not reachable Further Troubleshooting required\e[0m"
  sleep 3
 fi;
}
ping
