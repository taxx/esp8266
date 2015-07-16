l = file.list();
for k,v in pairs(l) do
  print(k)
  print(v)
end

a=require("autoupdate")
a.setup("Temperature")
a.tryUpdate("testing44.lua")

a=nil
package.loaded["autoupdate"]=nil


a.updateFiles("Temperature")
a=nil
package.loaded["autoupdate"]=nil
t="test"
print(t)
t = t.."Testare".."/"
print(t)


local v_path = "/IoT/"
subPath = "Temperature"
v_path = v_path..subPath.."/"
print(v_path)

a2 = "test"
print("a2:", a2)

print(v_path)

    a = 1   -- create a global variable
    -- change current environment to a new empty table
    setfenv(1, {})
    print(a)

    collectgarbage();


ttt = "Testing"
print(string.find(ttt,"bert"))

payload = "HTTP/1.1 404 Not Found\n\n                                               "
print(string.sub(payload,0,15)) -- HTTP/1.1 404 Not Found
print(string.sub(payload,string.find(payload,"HTTP/1.1"),22)) -- HTTP/1.1 404 Not Found
print(string.sub(payload,string.find(payload,"HTTP/1.1"),15)) -- HTTP/1.1 404 Not Found
print(string.sub(payload,string.find(payload,"HTTP/1.1"),15))
