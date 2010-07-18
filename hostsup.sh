#! /bin/sh
hubvm_name="HubVM"
hubvm_ip_string="$(VBoxManage guestproperty enumerate $hubvm_name | grep -i 'ip')"
hubvm_ip_key_string="$(echo $hubvm_ip_string | cut -d',' -f1 | sed 's/^ *\(.*\) *$/\1/')"
hubvm_ip_key="$(echo $hubvm_ip_key_string | cut -d':' -f2 | sed 's/^ *\(.*\) *$/\1/')"
hubvm_ip_value="$(VBoxManage guestproperty get $hubvm_name $hubvm_ip_key | grep -i 'value')"
hubvm_ip="$(echo $hubvm_ip_value | cut -d':' -f2 | sed 's/^ *\(.*\) *$/\1/')"

#The following is to modify '/etc/hosts' to use the current IP address of the VM.

if [ $hubvm_ip != "" ]; then
   #Make sure the IP address of the VM is not empty.
   cat /etc/hosts | grep -vi 'hubvm' > /tmp/hosts
   echo "$hubvm_ip hubvm.dev" >> /tmp/hosts
   echo "$hubvm_ip hubvm.touch.dev" >> /tmp/hosts
   echo "$hubvm_ip hubvm.exports.dev" >> /tmp/hosts
   echo "$hubvm_ip hubvm.wm.dev" >> /tmp/hosts
   sudo mv /tmp/hosts /etc/hosts
   echo "Your hosts file has been updated."
else
   echo "Unable to get the current IP address of the VM. Quit."
   exit 1;
fi;
