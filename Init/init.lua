-- Wait for WiFi init script
-- from http://www.esp8266.com/viewtopic.php?f=18&t=628
function wait_wifi()
  count = count + 1
  wifi_ip = wifi.sta.getip()
  if wifi_ip == nil and count < 20 then
     wifi.setmode(wifi.STATION)
     wifi.setphymode(wifi.PHYMODE_B)
     wifi.sta.config (ssid, wifiPassword, 1) -- readinf ssid + wifiPassword from variables set by config.lua
     wifi.sta.connect()

     tmr.alarm(0, 1000, 0, wait_wifi)
  elseif count >= 20 then
    wifi_connected = false
    print("Wifi connect timed out.")
    node.restart()
  else
    --wifi_connected = true
    print("Got IP "..wifi_ip.."\n")
    tmr.stop(6) -- Stopping watchdog timer since everything is OK!
    count=0
    wifi_ip=nil
    ssid=nil
    wifiPassword=nil

    dofile("init2.lua")
  end
end

function readvdd()
   wifi.sta.disconnect()
   voltage = adc.readvdd33()/1000
   print("Voltage: "..voltage)
end

-- Starting a watchdog timer to automatically reboot if we are stuck on something.
tmr.alarm(6, 60000, 0, function() 
  node.restart()
end )

count=0
dofile("config.lua") -- loading settings from file
--readvdd()
wait_wifi()
