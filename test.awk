#!/bin/bash
cd /home/pi/btooth

awk '
function randdelay(max) { 
	return 1+(rand()*65535 % max)
}
function sleep(time) {
   time += randdelay(1)
   system("sleep " time)
}

function publish(ctime, locale, person, status) {
  q = "'\''"
  host = "alarm"
  msg = sprintf("%s,%s,%s,%s", ctime, locale,  person, status)
  print(msg)
}

BEGIN  {

  interval = "45s"
  host = "alarm"
  q = "'\''"
  locale = "addison" 
  file = "btooth.txt"
  while(getline < file) {
	data[$2] = $1
  }

  while(1) {


  for (mac in data) {
  	ctime = systime()
	cmd = "hcitool name " mac
	person = data[mac]
	result = ""
	cmd | getline result 
	print(mac, result)
	close(cmd)
        status = 0	
	if (length(result) > 0) {
		status = 1
	}

	print(cmd, result, flag, person, status)
        publish(ctime, locale, person, status )

   sleep(randdelay(5))
   }

   print("sleeping")
   sleep(interval)
 }
}'
