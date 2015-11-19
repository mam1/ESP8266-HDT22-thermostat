version = "0.0.1"
CHANNEL_API_KEY = "WLDS1EKH6GRTK2QN"
delay = 6000
PINS =   {1,1}  --DHT22 data pin
FIELDS = {1,2}  --ThingSpeak fields
pinptr = 1

-- setup I2c and connect display
function init_i2c_display()
     -- SDA and SCL can be assigned freely to available GPIOs
     local sda = 5 -- GPIO14
     local scl = 6 -- GPIO12
     local sla = 0x3c
     print("  initializng I2c OLED display on pins "..sda.." and "..scl)    
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
     disp:setColorIndex(1)
end

function ascii_1()
    print("ascii_1 called")
     local x, y, s
     disp:drawStr(0, 0, "ASCII page 1")
     for y = 0, 5, 1 do
          for x = 0, 15, 1 do
               s = y*16 + x + 32
               disp:drawStr(x*7, y*10+10, string.char(s))
          end
     end
end

function dispit(line,text1,text2,text3)

   --picture loop
  disp:firstPage() 
  while disp:nextPage() do 
    disp:drawStr(0,line,text1)
    disp:drawStr(0,(line+15),text2)
    disp:drawStr(0,(line+25),text3)
  end
 
end

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
    dispit(10,"Office Sensor","   temp - "..send.."deg","   humidity - ")
    post(CHANNEL_API_KEY,FIELDS[pinptr],tostring(send/10).."."..tostring(send % 10))
	pinptr = pinptr + 1
	if pinptr > #PINS then pinptr = 1 end
end

-- ************** start main loop ********************
    print("\n\n*** thermo.lua  version "..version.." ***")
    init_i2c_display()


    
if (#PINS ~= #FIELDS) then 
	print("\n***** pin count and field count do not match\naborting")
else

	print("  reading "..(#PINS / 2).." HDT22 sensor\n  posting data to ThingSpeak api key "..CHANNEL_API_KEY)
	print("  running update every " .. delay .. "ms\n")

	tmr.alarm(0, delay, 1, update) 
end
