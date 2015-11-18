function init_OLED(sda,scl) --Set up the u8glib lib
     sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
end

function draw()
  disp:setColorIndex(1)
  disp:drawBox(10, 12, 20, 38)  
  disp:setFont(u8g_font_osb35)
  disp:drawStr(40, 50, "A")
  disp:setColorIndex(0)
  disp:drawPixel(28, 14) 
end

init_OLED(5,6) --Run setting up
print("start")

--picture loop
  disp:firstPage() 

    while disp:nextPage() do 
        draw()
        end


print("done")