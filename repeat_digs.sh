#/bin/bash -X
output=`dig @10.23.0.211 link.savetheprincesszelda.com +short`
#echo $output
#echo "Going to while loop"
while [ $output == 10.23.0.5 ];
do
  output=`dig @10.23.0.211 link.savetheprincesszelda.com +short`
  date=`date`
  #echo $output
  # echo "OK!"
done

echo "Failed, received at $date"
