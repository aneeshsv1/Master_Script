function CheckShadowLock
 {
  if [[ `cat /etc/shadow | awk -F ":" '$1 == "$1" {print $2}'` == '!!'* ]]
  then return 99
  else
   if [[ `cat /etc/shadow | awk -F ":" '$1 == "$1" {print $2}'` == '!'* ]]
   then return 98
   fi
  fi
 }
CheckShadowLock $selection
