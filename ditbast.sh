((df --total -H -x devtmpfs -x tmpfs -x overlay; lsblk; cat /etc/os-release; lscpu; ip a; free --mega) | less) && (rpm -qa | less) && (((ps -eF | grep node) && node_exporter --version) | less)
