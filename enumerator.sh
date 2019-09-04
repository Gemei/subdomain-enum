#!/bin/bash

if [ -z "$1" ];then
        echo "[*] Usage   : $0 <crt.sh URL> 
          ** example (./enumerator.sh https://crt.sh/?q=example.com)"
        exit 0
fi

for x in {1..100};do
    if [ ! -f 'tmp.domains.'$x ]; then
        touch tmp.domains.$x
        tmpFileName='tmp.domains.'$x
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

targetName=$(echo $1 | cut -d"=" -f2)

resulsts=$(curl -s $1 | grep 'href="?id=' | grep -Eo '[0-9]{1,50}' | uniq)

numbOfIDs=$(echo $resulsts | tr " " "\n" | wc -l)

incrementNumber=$(awk "BEGIN {print (100)/$numbOfIDs}")
progressCounter=$incrementNumber
counter=1

for id in $resulsts;do
	progressbar $progressCounter $counter $numbOfIDs
	domains=$(curl -s 'https://crt.sh/?id='$id | grep -oP '(?<=DNS:).*?(?=<BR>)')
	echo $domains >> $tmpFileName
	progressCounter=$(awk "BEGIN {print $progressCounter + $incrementNumber}")
	counter=$(($counter+1))
done
echo
cat $tmpFileName | tr " " "\n" | sort | uniq | grep -v '^*' > $targetName'.domains.list.txt'
echo $tmpFileName
rm $tmpFileName