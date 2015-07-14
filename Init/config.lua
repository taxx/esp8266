file.open("data.lua","r")
print("----------------------------")
print("Loading config from data.lua")
repeat
 line = file.readline()
  if line ~= nil then
        print(line)
        pcall(loadstring(line))
  end
until line == nil
file.close()
print("----------------------------")