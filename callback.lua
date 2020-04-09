
-----------------------------------------------------------------------------------------
--
-- callback.lua
--
-----------------------------------------------------------------------------------------

require("menu")
require("audio")

callback = {}

callback.callback_array = {}
local main_flow
local current_stage
local key_down = 0
local double_key_down = 0
local long_tap = 0
local right_data = {}
local left_data = {}
local test_size = 6

local audioRight = audio.loadSound("right_eye.mp3")
local audioLeft = audio.loadSound("left_eye.mp3")
local audioReset = audio.loadSound("reset.mp3")
local audioSkip = audio.loadSound("skip.mp3")
local audioTap = audio.loadSound("button.mp3")
local audioComplete = audio.loadSound("complete.mp3")

-- Get the Device resolution first

local screen_width = display.contentWidth
local screen_height = display.contentHeight
local check_key = 1


--Sleep function
local function Sleep(n)
   local t0 = os.clock()
   while os.clock() - t0 <= n do end
end


-- key event process
local last_keydown = 0

local function onKeyEvent( event )

    local sys_timer=system.getTimer()

    if(event.phase == "up") then
        if(sys_timer-last_keydown >= 5000) then
          long_tap = 1
          print("long tap!")
        else
          long_tap = 0
        end
        return false
    end

    if ( event.keyName == "back" or event.keyName == "forward" or event.keyName == "homePage") then
           if ( system.getInfo("platform") == "android" ) then
               return false
           end
    end

    if(check_key == 1 and sys_timer-last_keydown >= 20) then
        if(sys_timer-last_keydown <= 300) then
            double_key_down = 1
            last_keydown = sys_timer
            return true
        end
        double_key_down = 0
        last_keydown = sys_timer
    end


    if(check_key == 1) then
      key_down = 1
    end

    return true
end

--check gyroscope

local gyro_dgree_x = 0
local gyro_dgree_y = 0
local gyro_dgree_z = 0
local gyro_time_x = 0
local gyro_time_y = 0
local gyro_time_z = 0
local g_threshold = 6

local dis_txt

local function onGyroscopeDataReceived( event )

    local deltaRadians = event.xRotation * event.deltaTime
    local deltaDegrees_x = deltaRadians * (180/math.pi)

    deltaRadians = event.yRotation * event.deltaTime
    local deltaDegrees_y = deltaRadians * (180/math.pi)

    --dis_txt.text = string.format("%d,%d,%d",gyro_dgree_y,gyro_time_y,deltaDegrees_y)
    if(gyro_dgree_y == 0) then
      if(math.abs(deltaDegrees_y) >= g_threshold) then
        gyro_dgree_y = deltaDegrees_y
        gyro_time_y = event.deltaTime
      end
    else
      gyro_dgree_y = gyro_dgree_y + deltaDegrees_y
      gyro_time_y = gyro_time_y + event.deltaTime

      if(gyro_dgree_y <= 2) then
        gyro_dgree_y = 0
        gyro_time_y = 0
        key_down = 1
      elseif(gyro_time_y >= 1.1) then
        gyro_dgree_y = 0
        gyro_time_y = 0
      end
    end

    deltaRadians = event.zRotation * event.deltaTime
    local deltaDegrees_z = deltaRadians * (180/math.pi)


end


if system.hasEventSource( "gyroscope" ) then
    --Runtime:addEventListener( "gyroscope", onGyroscopeDataReceived )
end

--font_size = screen_width / 25
--dis_txt = display.newText(string.format("%d",0),screen_width/2+font_size*3,screen_height/2+font_size*10,native.systemFont,font_size)

-- Add the key event listener
Runtime:addEventListener( "key", onKeyEvent )

--fill background
local function onObjectTap( event )
    key_down = 1
    return true
end

local function fill_bkground(color)
  --local paint = { 1,1,0,0.2}
  bk_rect = display.newRect( screen_width/2, screen_height/2, screen_width, screen_height )
  bk_rect.fill = color
  bk_rect:addEventListener( "tap", onObjectTap )
end

--draw init screen

local left_black_plane
local right_black_plane


local function draw_initscreen(param)

  --draw seprate line

  local sep_line = display.newLine( 0,screen_height/2,screen_width,screen_height/2)
  sep_line:setStrokeColor( 1,1,0,0.7 )
  sep_line.strokeWidth = 4

  --draw cross line in each fields
  local left_center_x = screen_width/2
  local left_center_y = screen_height/4
  local right_center_x = screen_width/2
  local right_center_y = screen_height/4*3

  local cross_11 = display.newLine( screen_width/2-screen_width/40,screen_height/4,screen_width/2+screen_width/40,screen_height/4)
  cross_11:setStrokeColor( 1,1,0,0.7 )
  cross_11.strokeWidth = 4

  local cross_12 = display.newLine( screen_width/2,screen_height/4-screen_width/40,screen_width/2,screen_height/4+screen_width/40)
  cross_12:setStrokeColor( 1,1,0,0.7 )
  cross_12.strokeWidth = 4

  local cross_21 = display.newLine( screen_width/2-screen_width/40,screen_height/4*3,screen_width/2+screen_width/40,screen_height/4*3)
  cross_21:setStrokeColor( 1,1,0,0.7 )
  cross_21.strokeWidth = 4

  local cross_22 = display.newLine( screen_width/2,screen_height/4*3-screen_width/40,screen_width/2,screen_height/4*3+screen_width/40)
  cross_22:setStrokeColor( 1,1,0,0.7 )
  cross_22.strokeWidth = 4

  --creat two black rect for use in check stage
  left_black_plane = display.newRect(screen_width/2,screen_height/4-1,screen_width,screen_height/2-1)
  left_black_plane:setFillColor(0)
  left_black_plane.isVisible = false

  right_black_plane = display.newRect(screen_width/2,screen_height/4*3-1,screen_width,screen_height/2-1)
  right_black_plane:setFillColor(0)
  right_black_plane.isVisible = false


end


--creat a circle object

local scr_width = display.contentWidth
local scr_height = display.contentHeight

local point_size = display.contentWidth/200
local dis_point = display.newCircle(0, 0, point_size )
dis_point:setFillColor(1,1,0,1)
dis_point.isVisible = false

local function set_point_attr(os_od,dis_x,dis_y,dis_strength)
  if (os_od == 0) then
    --left field
      dis_x = scr_width/2 + dis_x
      dis_y = scr_height/4 + dis_y
    else
      dis_x = scr_width/2 + dis_x
      dis_y = scr_height/4*3 + dis_y
  end

  dis_point.x = dis_x
  dis_point.y = dis_y
  dis_point:setFillColor(dis_strength,dis_strength,0,1)
end

--Generate test point data list

local function generate_list(size)
  print("call genarate list")
  local my_list = {}
  local x_range = scr_width
  local y_range = scr_height / 2

  local range = 0
  if(x_range < y_range) then
    range = x_range
  else
    range = y_range
  end

  local block_size = range / size
  local x
  local y
  local i
  local j
  local index = 1

  for i=0,size,1 do
    for j=0,size,1 do
      x = j*block_size + block_size/2 - range/2
      y = range/2 - (i*block_size + block_size/2)
      s = x^2+y^2
      if(s<=(range/2)^2) then
        my_list[index] = {x,y,1,0}
        index = index + 1
      end
    end
  end

  --chaos the order

  index = index-1
  for i=0,size^2,1 do
    x = math.random(1,index)
    y = math.random(1,index)
    local p = my_list[x]
    my_list[x] = my_list[y]
    my_list[y] = p
  end

  return my_list

end

--blinking point module

local blinking_count = 0
local blinking_area = 0
local blinking_x = 0
local blinking_y = 0
local blinking_strength = 1
local max_wait = 20
local point_checked = 0
local test_interval = {}
local average_interval = 20

local function blinking_init()
  local i
  for i=0,19,1 do
    test_interval[i] = 20
  end
end

local function update_interval_list(interval)
  local i
  local j
  for i=0,19,1 do
    if(test_interval[i]>interval) then
      for j=19,i+1,-1 do
        test_interval[j] = test_interval[j-1]
      end
      test_interval[i] = interval
      break
    end
  end

  local total_interval = 0
  for i=10,19,1 do
    total_interval =total_interval + test_interval[i]
  end

  average_interval = total_interval / 10

end




function callback.blinking_point(event)

  if(blinking_count < 0) then
    return 0
  end

  blinking_count = blinking_count + 1
  set_point_attr(blinking_area,blinking_x,blinking_y,blinking_strength)

  if(blinking_count < 3) then
    dis_point.isVisible = true
  else
    dis_point.isVisible = false
  end

  if(key_down == 1) then
    key_down = 0


    if(point_checked == 0) then
      update_interval_list(blinking_count)
      --media.playSound( "button.mp3" )
      audio.play(audioTap)
      max_wait = blinking_count + 10
      if(math.random(1,10)>=8) then
        max_wait = max_wait + 10
      end
      point_checked = 1
    end
  end

  if(blinking_count > max_wait) then
    blinking_count = -1
  end

end

--check a group of points
local point_index = 1
local points_list
local area_retry = 0

function callback.check_area(event)

  --point blinking, do nothing
  if(blinking_count >= 0) then
    return 0
  end

  --double click, reset checking
  if(double_key_down == 1) then
      double_key_down = 0
      if(current_stage == "right check") then
          current_stage = "title screen"
          left_black_plane.isVisible = false
      elseif (current_stage == "left check") then
          current_stage = "right check"
          right_black_plane.isVisible = false
      end
      --media.playSound( "reset.mp3" )
      audio.play(audioReset)
      timer.performWithDelay( 3000, main_flow )
      --main_flow(current_stage)
      print("Reset!")
  end

  --record data
  if(point_index > 1) then
    points_list[point_index-1][4] = point_checked
    if(point_checked == 0) then
      points_list[point_index-1][3] = points_list[point_index-1][3] + 1
    end
  end

  --long tap, skip to next stage
  if(long_tap == 1) then
      long_tap = 0
      local i = 1

      while(points_list[i])
      do
        points_list[i][3] = 1
        points_list[i][4] = 1
        i = i+1
      end
      print("skip!")
      --media.playSound( "skip.mp3" )
      audio.play(audioSkip)
      Sleep(4)
  end

  --switch to next position
  point_index =  math.random(1,test_size*test_size)

  while(points_list[point_index])
  do
    if((points_list[point_index][3] < 4 and points_list[point_index][4] == 0)) then
      break
    end
    point_index = point_index + 1
  end

  if(not(points_list[point_index])) then
    point_index = 1
    while(points_list[point_index])
    do
      if((points_list[point_index][3] < 4 and points_list[point_index][4] == 0)) then
        break
      end
      point_index = point_index + 1
    end
  end

  if(points_list[point_index]) then
    blinking_x = points_list[point_index][1]
    blinking_y = points_list[point_index][2]
    blinking_count = 0
    blinking_strength = points_list[point_index][3] * 0.33
    key_down = 0
    point_checked = 0
    max_wait = math.min(average_interval + 5, 20)
    --print(point_index,points_list[point_index][3],points_list[point_index][4])
    point_index = point_index + 1
  else
    --Never retry to save time
    --if(area_retry == 0) then
    if(false) then
      point_index = 1
      while(points_list[point_index])
      do
        if(points_list[point_index][4] == 0) then
          points_list[point_index][3] = 1
        end
        point_index = point_index + 1
      end
      point_index = 1
      area_retry = 1
    else
      point_index = -1
      main_flow(current_stage)
    end
  end
end

local function add_callback(func)
  local i = 1
  while (callback.callback_array[i])
  do
    if(callback.callback_array[i] == func) then
      return 0
    end
    i = i+1
  end

  callback.callback_array[i] = func
end

local function remove_callback(func)
  local i = 1
  while (callback.callback_array[i])
  do
    if(callback.callback_array[i] == func) then
      local j = i+1
      while(1)
      do
        callback.callback_array[i] = callback.callback_array[j]
        if(callback.callback_array[j] == nil) then
          return 0
        end
        i = i+1
        j = j+1
      end
    end
    i = i+1
  end
end

local function remove_all_callback(param)
  local i = 1
  while (callback.callback_array[i])
  do
    callback.callback_array[i] = nil
    i = i+1
  end
end



local function copy_data(sou,des)
  local i = 1
  while(sou[i])
  do
    des[i] = {0,0,0,0}
    des[i][1] = sou[i][1]
    des[i][2] = sou[i][2]
    des[i][3] = sou[i][3]
    des[i][4] = sou[i][4]
    i = i+1
  end
end

function callback.init(param)
    --test_data(0)
    system.setIdleTimer(false)
    current_stage = "init"
    main_flow("init")
end



local function test_data(param)

  local my_list = generate_list(4)
  local i = 1
  while (my_list[i])
  do
    display.newCircle(scr_width/2+my_list[i][1], scr_height/4+my_list[i][2], display.contentWidth/200 ):setFillColor(1,1,0,1)
    i =i+1
  end


  local i = 1
  while(right_data[i])
  do
    print(right_data[i][3],right_data[i][4])
    i = i+1
  end

  i = 1
  while(left_data[i])
  do
    print(left_data[i][3],left_data[i][4])
    i = i+1
  end
end

local result_group
local function display_result(param)
  local x_range = scr_width
  local y_range = scr_height / 2
  result_group = display.newGroup()

  local range = 0
  if(x_range < y_range) then
    range = x_range
  else
    range = y_range
  end

  local x_center = scr_width / 2
  local y_center = (scr_height / 4) * 3

  local block_size = (range / test_size) * 0.8

  --draw right result
  local i =1
  local my_rect
  local gray_lvl
  while(right_data[i])
  do
    my_rect = display.newRect(result_group,right_data[i][1]+x_center,right_data[i][2]+y_center,block_size,block_size)
    gray_lvl = (4-right_data[i][3])*0.33 * 0.9
    my_rect:setFillColor(gray_lvl)
    --my_cycle = display.newCircle(result_group,right_data[i][1]+x_center,right_data[i][2]+y_center,4)
    --my_cycle:setFillColor(1,1,0)
    i =i+1
  end

  --draw left result
  i = 1
  y_center = scr_height / 4

  while(left_data[i])
  do
    my_rect = display.newRect(result_group,left_data[i][1]+x_center,left_data[i][2]+y_center,block_size,block_size)
    gray_lvl = (4-left_data[i][3])*0.33 * 0.9
    my_rect:setFillColor(gray_lvl)
    --my_cycle = display.newCircle(result_group,right_data[i][1]+x_center,right_data[i][2]+y_center,4)
    --my_cycle:setFillColor(1,1,0)
    i =i+1
  end
end

local title_visible = 0
local title_image
local image_name
function callback.title_screen(param)
  if(title_visible == 0) then
    title_image = display.newImageRect( image_name, scr_width, scr_height )
    title_image.x = display.contentCenterX
    title_image.y = display.contentCenterY
    title_image.isVisible = true
    title_visible = 1
    key_down = 0
  end

  if(key_down == 1) then
    key_down = 0
    main_flow(current_stage)
    title_image:removeSelf()
    title_image = nil
  end
end

local is_saved = 0

function callback.result_screen(param)
  if(title_visible == 0) then
    title_image = display.newImageRect( image_name, scr_width, scr_height )
    title_image.x = display.contentCenterX
    title_image.y = display.contentCenterY
    title_image.isVisible = true
    title_visible = 1
    key_down = 0
  end

  if(key_down == 1 and is_saved == 1) then
    key_down = 0
    main_flow(current_stage)
    title_image:removeSelf()
    title_image = nil
  end
end

local left_cycle = nil
local right_cycle = nil
function callback.cycle_screen(param)
  local cycle_area = math.min(screen_width,screen_height/2)
  local cycle_size = (cycle_area-cycle_area/math.max(test_size,6))/2
  if(left_cycle == nil) then
    left_cycle = display.newCircle( screen_width/2, screen_height/4, cycle_size )
    left_cycle:setStrokeColor(1,1,0 )
    left_cycle:setFillColor(1,1,0,0.1)
    left_cycle.strokeWidth = 4
    key_down = 0
  end

  if(right_cycle == nil) then
    right_cycle = display.newCircle( screen_width/2, screen_height/4*3, cycle_size )
    right_cycle:setStrokeColor(1,1,0 )
    right_cycle:setFillColor(1,1,0,0.1)
    right_cycle.strokeWidth = 4
    key_down = 0
  end

  if(key_down == 1) then
    key_down = 0
    main_flow(current_stage)
    if(left_cycle ~= nil) then
      display.remove(left_cycle)
      left_cycle = nil
    end
    if(right_cycle ~= nil) then
      display.remove(right_cycle)
      right_cycle = nil
    end
  end
end


local function copyFile( srcName, srcPath, dstName, dstPath )

    local results = false

    -- Copy the source file to the destination file
    local rFilePath = system.pathForFile( srcName, srcPath )
    --local wFilePath = system.pathForFile( dstName, dstPath )
    local wFilePath = dstPath .. dstName

    local rfh = io.open( rFilePath, "rb" )
    local wfh, errorString = io.open( wFilePath, "wb" )

    if not ( wfh ) then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        return false
    else
        -- Read the file and write to the destination directory
        local data = rfh:read( "*a" )
        if not ( data ) then
            print( "Read error!" )
            return false
        else
            if not ( wfh:write( data ) ) then
                print( "Write error!" )
                return false
            end
        end
    end

    rfh:close()
    wfh:close()
end

local function saveData()

  local screenCap = display.captureScreen(false)
  local date = os.date( "*t" )
  f_prefix = string.format("%04d%02d%02d_%02d%02d%02d",date.year,date.month,date.day,date.hour,date.min,date.sec)
  f_name = f_prefix .. ".png"
  display.save( screenCap, { filename=f_name, baseDir=system.DocumentsDirectory, captureOffscreenArea=true, backgroundColor={0,0,0,0} } )
  screenCap:removeSelf()

  copyFile(f_name,system.DocumentsDirectory,f_name,"/storage/emulated/0/")
  os.remove( system.pathForFile( f_name, system.DocumentsDirectory ) )

  --save data CSV file
  f_name = f_prefix .. ".csv"
  local path = system.pathForFile( f_name, system.DocumentsDirectory )
  local file, errorString = io.open( path, "w+" )

  if(file) then
    local i =1
    local buf_string
    while(right_data[i])
    do
      buf_string = string.format("%d,%d,%d,%d,0\n",right_data[i][1],right_data[i][2],right_data[i][3],right_data[i][4])
      file:write(buf_string)
      i =i+1
    end

    --draw left result
    i = 1
    while(left_data[i])
    do
      buf_string = string.format("%d,%d,%d,%d,1\n",left_data[i][1],left_data[i][2],left_data[i][3],left_data[i][4])
      file:write(buf_string)
      i =i+1
    end

    file:close()

    copyFile(f_name,system.DocumentsDirectory,f_name,"/storage/emulated/0/")
    os.remove( system.pathForFile( f_name, system.DocumentsDirectory ) )

  else
    print(errorString)
  end
end

local function onSave(event)
  if(is_saved == 0) then

    --save screen
    event.target.isVisible = false

    --event.target.text = "已保存"
    --event.target.isVisible = true

    is_saved = 1
  end

  return true
end

local function main_flow_process(param)
  param = current_stage
  if(param == "init") then
    print(system.DocumentsDirectory)
    fill_bkground({ 1,1,0,0.2})
    draw_initscreen(0)
    current_stage = "cycle screen"
    remove_all_callback(0)
    main_menu.creat(main_flow_process)

  elseif(param == "cycle screen") then
    test_size = main_menu.get_data()
    current_stage = "title screen"
    remove_all_callback(0)
    callback.callback_array[1] = callback.cycle_screen

  elseif(param == "title screen") then
    --test_size = main_menu.get_data()
    current_stage = "right screen"
    title_visible = 0
    image_name = "right.png"
    remove_all_callback(0)
    callback.callback_array[1] = callback.title_screen
    audio.stop()
    --media.playSound( "right_eye.mp3" )
    audio.play(audioRight)

  elseif(param == "right screen") then
    --start right check
    blinking_count = 4
    blinking_area = 1
    point_index = 1
    points_list = generate_list(test_size)
    area_retry = 0
    current_stage = "right check"
    left_black_plane.isVisible = true
    blinking_init()

    remove_all_callback(0)
    audio.stop()
    callback.callback_array[1] = callback.blinking_point
    callback.callback_array[2] = callback.check_area

  elseif(param == "right check") then
    --save data
    copy_data(points_list,right_data)

    left_black_plane.isVisible = false
    current_stage = "left screen"
    title_visible = 0
    image_name = "left.png"
    remove_all_callback(0)
    callback.callback_array[1] = callback.title_screen
    audio.stop()
    --media.playSound( "left_eye.mp3" )
    audio.play(audioLeft)

  elseif(param == "left screen") then
    --start left check
    remove_all_callback(0)
    blinking_count = 4
    blinking_area = 0
    point_index = 1
    points_list = generate_list(test_size)
    area_retry = 0
    current_stage = "left check"
    right_black_plane.isVisible = true
    blinking_init()

    remove_all_callback(0)
    audio.stop()
    callback.callback_array[1] = callback.blinking_point
    callback.callback_array[2] = callback.check_area

  elseif(param == "left check") then
    --save data
    copy_data(points_list,left_data)
    right_black_plane.isVisible = false

    --current_stage = "result screen"
    --title_visible = 0
    --image_name = "result.png"
    --remove_all_callback(0)
    --callback.callback_array[1] = callback.title_screen

    --media.playSound( "complete.mp3" )
    audio.play(audioComplete)

    remove_all_callback(0)
    check_key = 0
    display_result(0)
    saveData()

    --create save buttone here
    save_text = display.newImageRect(result_group,"save.png",screen_width*0.1,screen_height*0.2)
    save_text.x = screen_width*0.1/2
    save_text.y = screen_height/2
    is_saved = 0
    save_text:addEventListener( "tap", onSave)

    current_stage = "after result"
    title_visible = 0
    image_name = "after result.png"
    remove_all_callback(0)
    callback.callback_array[1] = callback.result_screen

  elseif(param == "result screen") then
    --complete all checks
    remove_all_callback(0)
    check_key = 0
    display_result(0)

    --create save buttone here
    save_text = display.newImageRect(result_group,"save.png",screen_width*0.1,screen_height*0.2)
    save_text.x = screen_width*0.1/2
    save_text.y = screen_height/2
    is_saved = 0
    save_text:addEventListener( "tap", onSave)

    current_stage = "after result"
    title_visible = 0
    image_name = "after result.png"
    remove_all_callback(0)
    callback.callback_array[1] = callback.title_screen

  elseif(param == "after result") then
    display.remove(result_group)
    check_key = 1
    current_stage = "restart screen"
    title_visible = 0
    image_name = "restart.png"
    remove_all_callback(0)
    callback.callback_array[1] = callback.title_screen

  elseif(param == "restart screen") then
    --restart from the beginning

    current_stage = "title screen"
    remove_all_callback(0)
    main_menu.creat(main_flow_process)
  else
  end
end

main_flow = main_flow_process

return callback
