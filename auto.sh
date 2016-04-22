#!/bin/bash
which ruby
which rails

echo 'raspberry' | sudo -S su - pi -c "cd /home/pi/Desktop/taige && rails server -p 3000 -d Puma" 
echo 'raspberry' | sudo -S su - pi -c "cd /home/pi/Desktop/taisheng && sudo rails server -p 80 -d Puma" 
echo 'raspberry' | sudo -S su - pi -c "cd /home/pi/Desktop/taisheng && sudo service redis-server restart" 
echo 'raspberry' | sudo -S su - pi -c "cd /home/pi/Desktop/taisheng && redis-cli flushall" 

sudo /home/pi/Desktop/ble_scan
ruby ts.rb

while read line; do
    echo "$line"
    sudo lxterminal -e '/home/pi/Desktop/ts2 '$line' | less' &
    sleep 10
done < /home/pi/Desktop/ble_params.txt

rm -f /home/pi/Desktop/ble_params.txt
rm -f /home/pi/Desktop/ble_devicelist.txt



echo 'raspberry' | sudo -S su - pi -c "w3m http://0.0.0.0/home/index" &


cat

