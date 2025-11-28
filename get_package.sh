#!/bin/bash

echo "Content-Type: text/html"
echo ""

echo "<html>"
echo "<body>"
echo "<h1>Download Package</h1>"
read data
data=$(echo $data | sed 's/%2B/+/g' | awk -F'=' '{print $2}')
for i in $(ls /var/cache/apt/archives/ | grep $data ); do
    echo "<p>"
    echo "<a href=\"/var/cache/apt/archives/$i\" download>- $i</a>"
    echo "</p>"
done
echo "</body>"
echo "</html>"