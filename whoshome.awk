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

function readfile(rfile, array) {
  print("reading file", rfile)

  delete array[0]

  while((getline < rfile) > 0) {
	print("1", $1, "2",  $2 )
	array[$2] = $1
  }
  close(rfile)


}

function publish(ctime, locale, person, status) {
  q = "'\''"
  host = "alarm"
  msg = sprintf("%s,%s,%s,%s", ctime, locale,  person, status)
  print(msg)
  system("mosquitto_pub -t home -h " host " -m "q msg q)
}

BEGIN  {

  interval = "45s"
  host = "alarm"
  q = "'\''"
  locale = "addison" 
  file = "btooth.txt"
  data[0] = ""


  while(1) {

  readfile(file, data)

  for (mac in data) {
  	ctime = systime()
	cmd = "hcitool name " mac
	person = data[mac]
	result = ""
	cmd | getline result 
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
