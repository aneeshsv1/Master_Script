function ping {
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
ping
