
-----------------------------------------------------------------------------------------
--
-- main menu.lua
--
-----------------------------------------------------------------------------------------

require("strings")

main_menu = {}

local menu_group
local scr_width = display.contentWidth
local scr_height = display.contentHeight
local return_function
local detect_size = 6
local size_string = {"2","4","6","8","10","12","14","16"}
local size_text

function main_menu.destory(param)
  display.remove(menu_group)
end

local function onExit(event)
  system.setIdleTimer(true)
  native.requestExit()
end

local function onBKTap(event)
  main_menu.destory(0)
  return_function()
end

local function onMin(event)
  detect_size = detect_size - 2
  if(detect_size <= 2) then
    detect_size = 2
  end

  size_text.text = size_string[detect_size/2]

  return true
end

local function onPlus(event)
  detect_size = detect_size + 2
  if(detect_size >= 16) then
    detect_size = 16
  end

  size_text.text = size_string[detect_size/2]

  return true
end

local txt_x
local txt_y
local txt_z

local function onGyroscopeDataReceived( event )
    local deltaRadians = event.xRotation * event.deltaTime
    local deltaDegrees = deltaRadians * (180/math.pi)
    txt_x.text = string.format("%d", deltaDegrees)

    deltaRadians = event.yRotation * event.deltaTime
    deltaDegrees = deltaRadians * (180/math.pi)
    txt_y.text = string.format("%d", deltaDegrees)

    deltaRadians = event.zRotation * event.deltaTime
    deltaDegrees = deltaRadians * (180/math.pi)
    txt_z.text = string.format("%d", deltaDegrees)

end

local function debug_fun()
  local font_size = scr_width / 25
  if system.hasEventSource( "gyroscope" ) then
      Runtime:addEventListener( "gyroscope", onGyroscopeDataReceived )
      print("yes!")
  end

  txt_x = display.newText(menu_group,string.format("%d",0),scr_width/2+font_size*3,scr_height/2+font_size*10,native.systemFont,font_size)
  txt_y = display.newText(menu_group,string.format("%d",0),scr_width/2+font_size*3,scr_height/2+font_size*11,native.systemFont,font_size)
  txt_z = display.newText(menu_group,string.format("%d",0),scr_width/2+font_size*3,scr_height/2+font_size*12,native.systemFont,font_size)

end


function main_menu.creat(param)

  return_function = param
  local bk_img
  menu_group = display.newGroup()
  bk_img = display.newImageRect(menu_group,"title.png",scr_width, scr_height)
  bk_img.x = display.contentCenterX
  bk_img.y = display.contentCenterY
  bk_img.isVisible = true


  local font_size = scr_width*0.4/7
  --option_txt = display.newText(menu_group,"请设置检测精度",scr_width/2,scr_height/2-font_size*4,native.systemFont,font_size*1.2)
  option_txt = display.newText(menu_group,str_01,scr_width/2,scr_height/2-font_size*4,native.systemFont,font_size*1.2)
  option_txt:setFillColor(1,1,0,1)

  min_txt = display.newText(menu_group,"←",scr_width/2-font_size*3,scr_height/2-font_size*2,native.systemFont,font_size*1.5)
  min_txt:setFillColor(1,1,0,1)
  min_txt:addEventListener( "tap", onMin)

  plus_txt = display.newText(menu_group,"→",scr_width/2+font_size*3,scr_height/2-font_size*2,native.systemFont,font_size*1.5)
  plus_txt:setFillColor(1,1,0,1)
  plus_txt:addEventListener( "tap", onPlus)

  size_text = display.newText(menu_group,size_string[detect_size/2],scr_width/2,scr_height/2-font_size*2,native.systemFont,font_size*1.5)
  size_text:setFillColor(1,1,0,1)

  --start_text = display.newText(menu_group,"开始检测",scr_width/2,scr_height-font_size*6,native.systemFont,font_size*1.2)
  start_text = display.newText(menu_group,str_02,scr_width/2,scr_height-font_size*6,native.systemFont,font_size*1.2)
  start_text:setFillColor(1,1,0,1)
  start_text:addEventListener( "tap", onBKTap)

  --exit_text = display.newText(menu_group,"退出程序",scr_width-font_size*3,scr_height-font_size*2,native.systemFont,font_size*1)
  exit_text = display.newText(menu_group,str_03,scr_width-font_size*3,scr_height-font_size*2,native.systemFont,font_size*1)
  exit_text:setFillColor(1,1,0,1)
  exit_text:addEventListener( "tap", onExit)

end

function main_menu.get_data(param)
  return detect_size
end



return main_menu
