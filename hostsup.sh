#! /bin/sh

hubvm_name="HubVM"
home_dir="/Users/felix_wang"


#This function is to update the hosts file.
update_host_file()
{
	if [ "$1" != "" ]; then
 		#Make sure the IP address of the VM is not empty.		
		#Here to strip the Windows New Line thingo...
		hubvm_dev=`expr "$1" : "\([0-9.]*\)"`
		cat /etc/hosts | grep -vi 'hubvm' > /tmp/hosts
		echo "$hubvm_dev hubvm.dev" >> /tmp/hosts
		echo "$hubvm_dev hubvm.touch.dev" >> /tmp/hosts
		echo "$hubvm_dev hubvm.exports.dev" >> /tmp/hosts
		echo "$hubvm_dev hubvm.wm.dev" >> /tmp/hosts
		sudo mv /tmp/hosts /etc/hosts
		echo "Your hosts file has been updated."
	else
		echo "Unable to get the current IP address of the VM. Quit."
		exit 1;
	fi;
}

#If you are running VirtualBox
vbox_hubvm_running="$(VBoxManage list runningvms | grep -i 'hubvm')"
if [ "$vbox_hubvm_running" != "" ]; then
	echo "Your VM is running in VirtualBox."
	hubvm_ip_string="$(VBoxManage guestproperty enumerate $hubvm_name | grep -i 'ip')"
	hubvm_ip_key_string="$(echo $hubvm_ip_string | cut -d',' -f1 | sed 's/^ *\(.*\) *$/\1/')"
	hubvm_ip_key="$(echo $hubvm_ip_key_string | cut -d':' -f2 | sed 's/^ *\(.*\) *$/\1/')"
	hubvm_ip_value="$(VBoxManage guestproperty get $hubvm_name $hubvm_ip_key | grep -i 'value')"
	hubvm_ip="$(echo $hubvm_ip_value | cut -d':' -f2 | sed 's/^ *\(.*\) *$/\1/')"

	#The following is to modify '/etc/hosts' to use the current IP address of the VM.
	update_host_file $hubvm_ip
else
	echo "No VM is running in VirtualBox."
fi;

#If you are running VM Fusion.
fusion_hubvm_running="$(/Library/Application\ Support/VMware\ Fusion/vmrun list | grep -i 'hubvm')"
if [ "$fusion_hubvm_running" != "" ]; then
	echo "Your VM is running in VMWare Fusion."

	#Put IP Address into a file on C Drive:
	/Library/Application\ Support/VMware\ Fusion/vmrun -T ws -h "$home_dir/Documents/Virtual\ Machines.localized/hubvm" -gu Administrator -gp hub runProgramInGuest "$home_dir/Documents/Virtual Machines.localized/hubvm.vmwarevm/hubvm.vmx" cmd.exe "/c C:\WINDOWS\system32\ipconfig.exe>C:\vmip.txt"
	#Copy the file from Guest OS to Host:
	/Library/Application\ Support/VMware\ Fusion/vmrun -T ws -h "$home_dir/Documents/Virtual\ Machines.localized/hubvm" -gu Administrator -gp hub copyFileFromGuestToHost "$home_dir/Documents/Virtual Machines.localized/hubvm.vmwarevm/hubvm.vmx" "C:\vmip.txt" "/tmp/vmip.txt"
	
	hubvm_ip_string="$(cat /tmp/vmip.txt | grep -i 'IP')"
	hubvm_ip="$(echo $hubvm_ip_string | cut -d':' -f2 | sed 's/^ *\(.*\) *$/\1/')"

	#The following is to modify '/etc/hosts' to use the current IP address of the VM.
  	update_host_file $hubvm_ip
else
	echo "No VM is running in VMWare Fusion."
fi;



