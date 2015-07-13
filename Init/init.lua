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
    wifi_connected = true
    print("Got IP "..wifi_ip.."\n")
    dofile("init2.lua")
  end
end

-- Wait for WiFi --
count=0
dofile("config.lua") -- loading settings from file
wait_wifi()