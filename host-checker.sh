#!/bin/bash

if [ -z "$1" ];then
        echo "[*] Usage   : $0 <File with list of hosts>
          ** example (./host-checker.sh hosts.txt)"
        exit 0
fi

for x in {1..100};do
    if [ ! -f 'tmp.hosts.'$x ]; then
        touch tmp.hosts.$x
        tmpFileName='tmp.hosts.'$x
        break;
    fi
done

# progress bar function
progressbar()
{
    bar="##################################################"
    barlength=${#bar}
    rounded=$(printf "%.0f\n" "$1")
    n=$(($rounded*barlength/100))
    printf "\r[%-${barlength}s (%.0f%%) %s/%s] " "${bar:0:n}" "$1" "$2" "$3"
}

targetName=$(echo $1 | cut -d"." -f1,2)

listOfHosts=$(cat $1)
numbOfHosts=$(cat $1 | wc -l)

incrementNumber=$(awk "BEGIN {print (100)/$numbOfHosts}")
progressCounter=$incrementNumber
counter=1

for host in $listOfHosts;do
	progressbar $progressCounter $counter $numbOfHosts
	status=$(ping -c1 $host -n 1 > /dev/null 2>&1; echo $?)
	if [ $status != "2" ];then
		echo $host >> $tmpFileName
	fi
	progressCounter=$(awk "BEGIN {print $progressCounter + $incrementNumber}")
	counter=$(($counter+1))
done
echo
cat $tmpFileName | tr " " "\n" | sort | uniq | grep -v '^*' > $targetName'.live.hosts.list.txt'
rm $tmpFileName