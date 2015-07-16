--http://stackoverflow.com/questions/29877118/lua-script-does-not-execute-in-sequence
print('httpget.lua started')

conn=net.createConnection(net.TCP, 0) 

-- show the retrieved web page
conn:on("receive", function (conn, payload)  
                     date = string.sub(payload,string.find(payload,"Date: ")
                     +0,string.find(payload,"Date: ")+35)
                     conn:close()
                     end) 

-- when connected, request page (send parameters to a script)
conn:on("connection", function(conn, payload) 
                       print('\nConnected') 
                       conn:send("HEAD /  HTTP/1.1\r\n" 
                        .."Host: google.com\r\n" 
                        .."Accept: */*\r\n" 
                        .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"
                        .."\r\n\r\n")
                        end)

-- when disconnected, let it be known
conn:on("disconnection", function(conn, payload)
                         print("Disconnected\r\n")
                         print("----------------")
                         print(date)
                         end)

conn:connect(80,'google.com')
conn=nil