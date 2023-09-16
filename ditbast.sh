((df --total -H -x devtmpfs -x tmpfs -x overlay; echo -e "\n"; lsblk; echo -e "\n"; cat /etc/os-release; echo -e "\n"; lscpu; echo -e "\n"; ip a; echo -e "\n"; free --mega) | less) && (rpm -qa | less) && (((ps -eF | grep node) && exec node_exporter --version) | less)

# exec part exists so that packagekit-commant-not-found wont be triggered if node_exporter doesnt exist


