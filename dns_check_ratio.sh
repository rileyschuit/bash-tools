#/bin/bash
# Command syntax example:  ./dns_check_ratio.sh 10.10.10.5 slapchop.com 10000
# This runs the number of queries mentioned in argument 3 and counts the unique results

i=0
while [ "$i" -lt "$3" ]; do
  i="$[$i+1]"
  dig @$1 $2 +short  >> ~/dig_output.txt
  result_ouput=`cat ~/dig_output.txt | wc -l`
  
  if [ $result_ouput -eq $3 ]; then
    echo "`awk -F '\t' '{printf("%s\n\n",$1)}'  ~/dig_output.txt | sort | uniq -c | sort -nr`"
    rm ~/dig_output.txt
  fi
  done

