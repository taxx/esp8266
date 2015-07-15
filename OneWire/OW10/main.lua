-- OWS sauna sleeper to thingspeak by Tobias
-- Requirements:
--  config.lua loading data.lua
--    Containing variables: apiKey, saunaTemperature
pin = 2   -- GPIO pin, 2 = use GPIO-5
data = "" -- data to be uploaded to thingspeak
temp = ""
shortSleep = 0 -- indicating shortsleep or normal sleep depending on the temperature of the sauna
--Rember to set this to false when running on battery! :-)
debug = false -- true here equals shorter deep sleep
 
function sendData(data, shortSleep)
   print("Sending data")

   --Connect to Thingspeak
   conn = nil
   conn = net.createConnection(net.TCP, 0) 
   conn:on("receive", function(conn, payload)
      print("Response received")
            if shortSleep >= 1 then
                if debug then
                   print("Entering short debug deep sleep for 10 seconds, good night!")
                   node.dsleep(10000000)
                else
                   print("Entering short deep sleep for 10 minutes, good night!")
                   node.dsleep(600000000)
                end
            else
                if debug then
                   print("Entering short debug deep sleep for 10 seconds, good night!")
                   node.dsleep(10000000)
                else
                   print("Entering long deep sleep for 30 minutes, good night!")
                   node.dsleep(1800000000)
                end

            end

   end)
   print("conn start")
   conn:on("connection", function(conn, payload) 
   conn:send("GET /update.php"
      .."?key="..apiKey
      ..data
      .." HTTP/1.1\r\n" 
      .."Host: api.thingspeak.com\r\n" 
      .."Connection: close\r\n"
      .."Accept: */*\r\n" 
      .."User-Agent: Mozilla/4.0 "
      .."(compatible; esp8266 Lua; "
      .."Windows NT 5.1)\r\n" 
      .."\r\n")
   end) 
   conn:on("disconnection", function(conn, payload) end)
   
   conn:connect(80,'api.thingspeak.com') --184.106.153.149
end

-- Main entrypoint

-- adding protection to automatically reboot if we are not sleeping.
-- means we are probably stuck somewhere
tmr.alarm(6, 60000, 0, function() 
  node.restart()
end )

print("Start reading sensors")
t=require("ds18b20")
t.setup(pin)
addrs=t.addrs()
counter = 1

if voltage ~= nil then
  data = "&field1".."="..voltage
  counter = 2
end

-- stop using x here
for x = 1, table.getn(addrs) do
   temp = t.read(addrs[x],t.C)
   -- Way to handle cases when sensor is 85
   for y = 1, 5 do
      temp = t.read(addrs[x],t.C)
      --temp = 85
      if temp ~= 85 then break end
      tmr.delay(1000000)
      print("Sensor read 85, thats probably wrong! reading again!")
   end
   
   -- Build string for thingspeak
   --data = data .. "&field"..x.."="..temp
   data = data .. "&field"..counter.."="..temp

   -- if sauna, then shorter sleep
   if temp >= saunaTemperature then
     --print("shortsleep!")
     shortSleep = 1
   end
   counter = counter + 1
end

t = nil
ds18b20 = nil
package.loaded["ds18b20"]=nil
addrs=nil

print(data)
sendData(data, shortSleep)
