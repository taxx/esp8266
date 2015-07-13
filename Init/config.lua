file.open("data.lua","r")
repeat
 line = file.readline()
 if line ~= nil then pcall(loadstring(line)) end
until line == nil
file.close()

print(apiKey)
print(saunaTemperature)
print(ssid)
print(wifiPassword)