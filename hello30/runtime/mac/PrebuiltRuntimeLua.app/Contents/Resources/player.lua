--[[
    file: player.lua

    player 的 lua 核心
]]

--
-- 返回 table 的字符串
--

local function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true

        if "string" == type(key) then
            table.insert(sb, string.format("%s ={\n", tostring(key)));
        else
            table.insert(sb, "{\n");    
        end

        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "},\n");
      elseif type(value) == "function" then

      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\",\n", tostring(value)))
      elseif type (value) == "number" then
                table.insert(sb, string.format(
            "%s = %s,\n", tostring (key), tostring(value)))

      elseif type (value) == "string" then
                table.insert(sb, string.format(
            "%s = \"%s\",\n", tostring (key), tostring(value)))

      elseif type (value) == "boolean" then
                table.insert(sb, string.format(
            "%s = %s,\n", tostring (key), tostring(value)))
      -- else
      --   table.insert(sb, string.format(
      --       "%s = \"%s\",\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

local function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end

--
-- save player setting to ~/.quick_player.lua
--
local player = {}
player.defaultSettings = [[
PLAYER_COCOACHINA_KEY = "USER_KEY",
PLAYER_COCOACHINA_USER = "USER_NAME",
PLAYER_WINDOW_X = 0,
PLAYER_WINDOW_Y = 0,
PLAYER_WINDOW_WIDTH = 960,
PLAYER_WINDOW_HEIGHT = 640,
PLAYER_OPEN_LAST_PROJECT = true,
PLAYER_OPEN_RECTNS ={
},

]]

function player.saveSetting(fileName)
    fileName = fileName or player.configFilePath
    local file, err = io.open(fileName, "wb")
    if err then return err end

    -- table.sort(cc.player.settings)
    local ret = to_string(cc.player.settings)
    file:write(ret)
    file:close()
end

function player.loadSetting(fileName)
    local file, err = io.open(fileName, "rb")
    if err then return err end

    local data = file:read("*all")
    local func = loadstring("local settings = {" .. data .. "} return settings")
    cc.player.settings = func()
end

function player.restorDefaultSettings()
    local func = loadstring("local settings = {" .. player.defaultSettings .. "} return settings")
    cc.player.settings = func()
    player.saveSetting()
end

--
-- title: string
-- args : table
--
function player.openProject( title, args )
    local welcomeTitle = __G__QUICK_PATH__ .. "player/welcome/"
    if title == welcomeTitle then return end

    local recents = cc.player.settings.PLAYER_OPEN_RECTNS
    if recents then
        local index = #recents
        while index > 0 do
            local v = recents[index]
            if v.title == title then table.remove(recents, index) end
            index = index - 1
        end
        table.insert(recents, 1, {title=title, args=args})
        cc.player.saveSetting()
    end
end

function player.clearMenu()
    cc.player.settings.PLAYER_OPEN_RECTNS = {}
    player.saveSetting()
end

function player.buildUI()
    -- local menu = PlayerProtocol:getInstance():getMenuService()
    -- local item = PlayerMenuItem:new()
    -- item.itemId = "MENU_MORE"
    -- item.title = "More";
    -- item.isGroup = true
    -- menu:addItem(item, "", 4)

    -- item.itemId= "MORE_UPGRADE"
    -- item.title = "Upgrade to full version";
    -- item.isGroup = false
    -- item.scriptHandlerId = function() print("run 'upgrade' script to upgrade to full version") end
    -- menu:addItem(item, "MENU_MORE")
end

function player.init()
    player.registerEventHandler()

    player.configFilePath = __USER_HOME__ .. ".quick_player.lua"
    if not cc.FileUtils:getInstance():isFileExist(player.configFilePath) then 
        player.restorDefaultSettings()
    end
    player.loadSetting(player.configFilePath)

    local s = PlayerSettings:new()
    s.offsetX = cc.player.settings.PLAYER_WINDOW_X
    s.offsetY = cc.player.settings.PLAYER_WINDOW_Y 
    s.windowWidth = cc.player.settings.PLAYER_WINDOW_WIDTH 
    s.windowHeight = cc.player.settings.PLAYER_WINDOW_HEIGHT 
    s.openLastProject = cc.player.settings.PLAYER_OPEN_LAST_PROJECT
    PlayerProtocol:getInstance():setPlayerSettings(s)
end

function player.registerEventHandler()
    player.eventNode = cc.Node:create()
    
    -- for app event
    local eventDispatcher = player.eventNode:getEventDispatcher()
    local event = function(e)
        local t = json.decode(e:getDataString())
        if t == nil then return end

        if t.name == "close" then
            -- player.trackEvent("exit")
            print("exit")
            eventDispatcher:dispatchEvent(cc.EventCustom:new("WELCOME_APP_HIDE"))
            -- cc.Director:getInstance():endToLua()
        elseif t.name == "resize" then
            -- <code here> t.w,t.h
        elseif t.name == "focusIn" then
            -- cc.Director:getInstance():resume()
        elseif t.name == "focusOut" then
            -- cc.Director:getInstance():pause()
        elseif t.name == "keyPress" then
            -- t.key = "tab"
            -- t.key = "return"
        end
    end

    eventDispatcher:addEventListenerWithFixedPriority(cc.EventListenerCustom:create("APP.EVENT", event), 1)
end

function player.trackEvent(eventName, ev)
    local url = 'http://www.google-analytics.com/collect'
    local request = cc.HTTPRequest:createWithUrl(function(event) 
                                                    local eventName = eventName
                                                    if eventName == "exit" then 
                                                        cc.Director:getInstance():endToLua() 
                                                    end 
                                                end,
                                                url, 
                                                cc.kCCHTTPRequestMethodPOST)

    request:addPOSTValue("v", "1")
    request:addPOSTValue("tid", "UA-52790340-1")
    request:addPOSTValue("cid", cc.Native:getOpenUDID())
    request:addPOSTValue("t", "event")

    request:addPOSTValue("an", "player")
    request:addPOSTValue("av", "alpha2")

    request:addPOSTValue("ec", device.platform)
    request:addPOSTValue("ea", eventName)
    -- request:addPOSTValue("el", "mac")

    if ev == nil then ev = "0" else ev = tostring(ev) end
    request:addPOSTValue("ev", ev)

    -- 开始请求。当请求完成时会调用 callback() 函数
    request:start()
end

function player.exit()
    local delta = os.time() - player.startClock
    player.trackEvent("exit", delta)
end

-- call from host
function player.start()
    player.startClock = os.time()
    player.trackEvent("launch")
end

-- load player settings


cc = cc or {}
cc.player = cc.player or player

cc.player.init()

function __PLAYER_OPEN__(title, args)
    cc.player.openProject(title, args)
    player.buildUI()
end