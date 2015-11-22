done = false

function dispNet()
--    print("   active networks:")
    wifi.sta.getap(function(t)
        for k,v in pairs(t) do
            print("      "..k.." "..v:sub(3,5).."dbi")
        end
    end)
end

-- print ap list
function listap(t)
      print("\nactive networks:")
      for k,v in pairs(t) do
        print("  "..k.." : "..v)
      end
end

function str()
    dofile("thermo.lua")
end

--init.lua
print('\n**** init.lua ver 1.4')
print('  set mode=STATION (mode='..wifi.getmode()..')')
print('  MAC: ',wifi.sta.getmac())
print('  chip: ',node.chipid())
print('  heap: ',node.heap())
-- wifi config start
wifi.sta.config("FrontierHSI","")
-- wifi config end
wifi.sta.connect()
tmr.alarm(1, 1000, 1, function()
	if wifi.sta.getip()== nil then
		print("IP unavaiable, Waiting...")
	else
		tmr.stop(1)
		print("\n   ESP8266 mode is: " .. wifi.getmode())
		print("   The module MAC address is: " .. wifi.ap.getmac())
		print("   Config done, IP is "..wifi.sta.getip())
        dofile("getNets.lua")
--        tmr.delay(10000000)   -- wait 1,000,000 us = 1 second       
--        dofile("thermo.lua")
        tmr.alarm(2,5000,0,str)
 	end
end)


