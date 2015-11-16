version = "0.0.0"
CHANNEL_API_KEY = "WLDS1EKH6GRTK2QN"
delay = 60000
PINS =   {1,1}
FIELDS = {1,2}

pinptr = 1
--get data from DHT22 sensor on <pin>
function rdDHT22(pin)
	local tmp, hmd
    print("\n  reading pin "..PINS[pinptr])
    dht22 = require("dht22_min")
	--read sensor
    dht22.read(PINS[pinptr])
    tmp = dht22.getTemperature()
    hmd = dht22.getHumidity()
	if tmp == nil then
    	print("*** Error reading temperature from DHT22")
    end
    if hmd == nil then
        print("*** Error reading humidity from DHT22")
    end
	--release DHT22 module
    dht22 = nil
    package.loaded["dht22"]=nil
	return tmp, hmd 
end

--post data <value> to ThingSpeak api key <key>, field <field>
function post(key,field,value)
    print("    posting pin "..PINS[pinptr].." data to field "..field.." value is "..value)   
    connout = nil
    connout = net.createConnection(net.TCP, 0)
    connout:on("receive", function(connout, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("    Posted OK");
        end
    end)
    connout:on("connection", function(connout, payloadout) 
        print ("    Posting...");       
        connout:send("GET /update?api_key="
        .. key
        .. "&field"
        .. field
        .."=" 
        .. value
        .. " HTTP/1.1\r\n"
        .. "Host: api.thingspeak.com\r\n"
        .. "Connection: close\r\n"
        .. "Accept: */*\r\n"
        .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
        .. "\r\n")
    end)
    connout:on("disconnection", function(connout, payloadout)
        connout:close();
        collectgarbage(); 
    end)
    connout:connect(80,'api.thingspeak.com')
end

function update()
	local t, h,send

    t, h = rdDHT22(PINS[pinptr])
    if pinptr % 2 ~= 0 then
        send = (t*9)/5 + 320
    	print("    posting temperature ")       
    else
        send = h
        print("    posting humidity ")
    end	
    post(CHANNEL_API_KEY,FIELDS[pinptr],tostring(send/10).."."..tostring(send % 10))
	pinptr = pinptr + 1
	if pinptr > #PINS then pinptr = 1 end
end

-- ************** start main loop ********************
if (#PINS ~= #FIELDS) then 
	print("\n***** pin count and field count do not match\naborting")
else
    print("\n\n*** thermo.lua  version "..version.." ***")
	print("  reading "..(#PINS / 2).." HDT22 sensor\n  posting data to ThingSpeak api key "..CHANNEL_API_KEY)
	print("  running update every " .. delay .. "ms\n")
--	tmr.alarm(0, delay, 1, update) 
end
