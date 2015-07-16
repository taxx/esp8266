--Version: 1
-- Module for doing automatic update of lua script of a webserver
-- Originally created by Thomas M.

-- Set module name as parameter of require
local modname = ...
local M = {}
_G[modname] = M

-- Local used variables
local conn = nil
local conn = net.createConnection(net.TCP, 0) 
local v_update = 0
local fileNotFound = true
--local v_str = ""
local v_con = 0
local v_host = "plym.se"
local v_path = "/IoT/"
local f_name = ""

-- Local used modules
local file = file
local string = string
local pairs = pairs
local print = print

-- Limited to local environment
setfenv(1,M)

-- Implementation start

-- Call setup with subpath, like "Temperature", the slash will be added
-- Idea is to place all lua files that are to be updated on the esp8266 in this subpath
-- Suporting multiple functions and a generic module in an IoT world
function setup(subPath)
  print("setup")
  v_path = v_path..subPath.."/"
  print("v_path: ", v_path)
end

function updateFiles(subPath)
	print("updateFiles")
    v_path = v_path..subPath.."/"
	
	l = file.list();
    for n,s in pairs(l) do  -- n = filename, s = filesize
      tryUpdate(n)
    end
end

function tryUpdate(filename)
  f_name = filename
  print(filename)
  print("TryUpdate")
  
	conn:on("receive", function(conn, payload)
	    print("TryUpdate.conn.receive")
		--print("payload:\n ", payload)
		--success = true
		print("v_con:",v_con)
	    
		if v_con == 0 then
		    
		    local httpCode = string.sub(payload,0,15)
			print("httpCode:", httpCode)
			if string.find(httpCode,"200") ~= nil then
			    fileNotFound = false
				v_str = string.sub(payload,string.find(payload,"Connection: close")+21,string.len(payload))
	
				version_check(f_name, v_str)
				if v_update == 1 then
					updateFile(f_name, v_str, 0)
				end
			else
				v_update = 0
			end
		elseif v_con > 0 and v_update == 1 then
			updateFile(f_name, payload, 1)
		end
		v_con = v_con + 1
		print("v_con:",v_con)
	end) 

	conn:on("connection", function(conn, payload)
	    print("TryUpdate.conn.connection")
		print('\nConnected') 
		--print("f_name: ",f_name)
		--print("POST: "..v_path..f_name)
		conn:send("POST "..v_path..f_name
		.." HTTP/1.1\r\n" 
		.."Host: "..v_host.."\r\n" 
		.."Connection: close\r\n"
		.."Accept: */*\r\n" 
		.."User-Agent: Mozilla/4.0 "
		.."(compatible; esp8266 Lua; "
		.."Windows NT 5.1)\r\n" 
		.."\r\n")
	end) 

	conn:on("disconnection", function(conn, payload)
        print("TryUpdate.conn.disconnection")
		print('Disconnected')
	    print("f_name: ",f_name)
		print("v_update: ", v_update)
		if fileNotFound then
			print(f_name.." was not found on server")
		else
			if v_update == 1 then
				updateFile(f_name, "  ", 1)
				print(f_name.." has been updated, current version is: ",v_serverversion)
			elseif v_update == 0 then
				print(f_name.." was already up to date, current version is: ",v_serverversion)
			end
		end
	end)
    
	print("making connection")
	conn:connect(80,v_host)
end

function version_check(filename, srvVersion)
	print("version_check")
	print(filename)
    local file_found = file.open(filename, "r")
    if file_found == nil then
        file.open(filename, "w")
            file.write("--Version: 0")
        file.close()
        v_update = 1
    else
        v_serverversion = string.match(srvVersion,"Version: (%d+)")
        file.open(filename, "r")
            v_currversion = string.match(file.read(),"Version: (%d+)")
        file.close()
		print("v_serverversion: " ,v_serverversion)
		print("v_currversion: " ,v_currversion)
        --if v_serverversion > v_currversion then
		if v_serverversion ~= v_currversion then
            v_update = 1
        else
            v_update = 0
        end
    end
end

-- when responses are read this one is called as the data comes in in chunks
-- first write to the file, then appending
function updateFile(filename, u_str, u_type)
    print("updateFile")
	print("filename: ", filename)
	print("u_type: ", u_type)
    if u_type == 0 then
        file.open(filename,"w+")
    else
        file.open(filename,"a")
    end
        file.write(u_str)
    file.close()
end

return M
