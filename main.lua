-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

math.randomseed( os.time() )

require("callback")

-- local notifications = require( "plugin.notifications" )
-- notifications.cancelNotification( )

--enter main loop

function main_loop(event)

  local i = 1
  while (callback.callback_array[i])
  do
    callback.callback_array[i](event)
    i = i + 1
  end
end

callback.init(0)

main_timer = timer.performWithDelay( 100, main_loop, 0 )
