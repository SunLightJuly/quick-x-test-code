
local BenchmarkScene = class("BenchmarkScene", function()
    return display.newScene("BenchmarkScene")
end)

local random = math.random

function BenchmarkScene:ctor()
    self.batch = display.newBatchNode(GAME_TEXTURE_IMAGE_FILENAME, 10000)
    self:addChild(self.batch)

    self.layer = display.newLayer()
    self:addChild(self.layer)

    -- self.bg = display.newSprite("bg.jpg", display.cx, display.cy)
    -- self:addChild(self.bg)

    local button = display.newSprite("#AddCoinButton.png", display.right - 100, display.bottom + 270)
    self:addChild(button)
    self.addCoinButtonBoundingBox = button:getBoundingBox()

    local button = display.newSprite("#RemoveCoinButton.png", display.right - 100, display.bottom + 100)
    self:addChild(button)
    self.removeCoinButtonBoundingBox = button:getBoundingBox()
    local sz = button:boundingBox().size
    print("-----size: ", sz.width, sz.height)
    print("-----getPosition: ", button:getPosition())

    local button = ui.newImageMenuItem({
        image = "#ExitButton.png",
        listener = function()
            game.exit()
        end,
        x = display.right - 100,
        y = display.top - 100,
    })
    local menu = ui.newMenu({button})
    self:addChild(menu)

    self.label = ui.newBMFontLabel({
        text = "00000",
        font = "UIFont.fnt",
        x = display.cx,
        y = display.top - 40,
    })
    self:addChild(self.label)

    self.coins = {}
    self.state = "IDLE"

    local frames = display.newFrames("CoinSpin%02d.png", 1, 8)
    local animation = display.newAnimation(frames, 0.4 / 8)
    display.setAnimationCache("Coin", animation)

    self.left   = display.left   + display.width / 4
    self.right  = display.right  - display.width / 4
    self.top    = display.top    - display.height / 3
    self.bottom = display.bottom + display.height / 3

    -- display.addSpriteFramesWithFile("SheetMapBattle.plist", "SheetMapBattle.png")
    -- self.testSprite = display.newSprite("#IncreaseHp0017.png", display.cx, display.cy)
    -- -- self:addChild(self.testSprite)
    -- self.batch1 = display.newBatchNode("SheetMapBattle.png", 5)
    -- self.batch1:addChild(self.testSprite)
    -- self:addChild(self.batch1)
end

function table.merge1(dest, src)
    local i = 0
    for k, v in pairs(src) do
        dest[k] = v
        i = i + 1
    end
    local mt = getmetatable(src)
    setmetatable(dest, mt)
    print("merged: ", i)
end

function BenchmarkScene:onTouch(event, x, y)
    -- self:removeNodeEventListener(self.handler)
    -- local tt = {}
    -- table.merge1(tt, tolua_gc)
    -- local mt = getmetatable(CCPoint)
    -- table.merge1(tt, mt["tolua_ubox"])
    -- if self.tbl and #self.tbl>0 then
    --     local tbl = self.tbl
    --     for i,v in ipairs(tbl) do
    --         tbl[i] = nil
    --     end
    --     self.tbl = nil
    -- end
    -- collectgarbage("collect")
    -- collectgarbage("collect")
    -- collectgarbage("collect")
    -- print("clean", collectgarbage("count"))
    -- local t = {}
    -- table.merge1(t, tolua_gc)
    -- tolua_gc = t
    -- local mt = getmetatable(CCPoint)
    -- t = {}
    -- table.merge1(t, mt["tolua_ubox"])
    -- mt["tolua_ubox"] = t
    -- collectgarbage("collect")
    -- collectgarbage("collect")
    -- collectgarbage("collect")
    -- print("--clean", collectgarbage("count"))
    -- return

    if event == "began" then
        local p = CCPoint(x, y)
        if self.addCoinButtonBoundingBox:containsPoint(p) then
            self.state = "ADD"
        elseif self.removeCoinButtonBoundingBox:containsPoint(p) then
            self.state = "REMOVE"
        else
            self.state = "IDLE"
        end
        return true
    elseif event ~= "moved" then
        self.state = "IDLE"
    end
end

function BenchmarkScene:addCoin()
    local coin = display.newSprite("#CoinSpin01.png")
    coin:playAnimationForever(display.getAnimationCache("Coin"))
    coin:setPosition(random(self.left, self.right), random(self.bottom, self.top))
    self.batch:addChild(coin)

    function coin:onEnterFrame(dt)
        local x, y = self:getPosition()
        x = x + random(-2, 2)
        y = y + random(-2, 2)
        self:setPosition(x, y)
    end

    self.coins[#self.coins + 1] = coin
    self.coinsCount = #self.coins
    self.label:setString(string.format("%05d", self.coinsCount))
end

function BenchmarkScene:removeCoin()
    local coin = self.coins[self.coinsCount]
    coin:removeSelf()
    table.remove(self.coins, self.coinsCount)
    self.coinsCount = self.coinsCount - 1
    self.label:setString(string.format("%05d", self.coinsCount))
end

function BenchmarkScene:onEnterFrame(dt)
    -- if not self.updateFlag then return end

    -- self.tbl = self.tbl or {}
    -- for i = 1, 10000 do
    --     local t = {}
    --     -- local t = self.tbl
    --     -- table.insert(t, CCPoint(i, i))
    --     -- CCPoint(0, 0)
    --     -- local t = display.newSprite("#AddCoinButton.png")
    --     -- table.insert(t, display.newSprite("#AddCoinButton.png"))
    --     table.insert(t, TestClass())
    -- end
    -- -- collectgarbage("collect")
    -- print("run", collectgarbage("count"))
    -- return

    if self.state == "ADD" then
        self:addCoin()
    elseif self.state == "REMOVE" and self.coinsCount > 0 then
        self:removeCoin()
    end

    local coins = self.coins
    for i = 1, #coins do
        local coin = coins[i]
        coin:onEnterFrame(dt)
    end

    -- if self.trackFlag==nil and coins[1] then
    --     local c = coins[1]
    --     -- local pt = cc.Vec2:new(0,0)
    --     local pt = cc.p(0,0)
    --     local socket = require "socket"

    --     self.trackStart = socket.gettime()
    --     for i = 1, 100000 do
    --         c:setPosition(0,0)
    --     end
    --     self.trackEnd = socket.gettime()
    --     print("=========================setPosition(0,0)")
    --     local ts = self.trackStart*1000
    --     print("----time start:", ts)
    --     local te = self.trackEnd*1000
    --     print("----time end:", te)
    --     print("----time used:", te-ts)

    --     self.trackStart = socket.gettime()
    --     for i = 1, 100000 do
    --         c:setPosition(pt)
    --     end
    --     self.trackEnd = socket.gettime()
    --     print("=========================setPosition(pt)")
    --     local ts = self.trackStart*1000
    --     print("----time start:", ts)
    --     local te = self.trackEnd*1000
    --     print("----time end:", te)
    --     print("----time used:", te-ts)

    --     self.trackStart = socket.gettime()
    --     for i = 1, 100000 do
    --         c:setPosition(cc.p(0,0))
    --     end
    --     self.trackEnd = socket.gettime()
    --     print("=========================setPosition(cc.p(0,0))")
    --     local ts = self.trackStart*1000
    --     print("----time start:", ts)
    --     local te = self.trackEnd*1000
    --     print("----time end:", te)
    --     print("----time used:", te-ts)

    --     self.trackFlag = 1
    -- end
end

function BenchmarkScene:onEnter()
    -- self.path = device.writablePath .."res/"
    -- local packageUrl = "http://www.yzjngg.com/g/weixin.zip"
    -- local versionUrl = "http://www.yzdfyy.com/m/index.php/index/version"
    -- self.assetsManager = AssetsManager:new(packageUrl,versionUrl,self.path)
    -- self.updateFlag = true

    -- local function testf(  )
    --     print("test stop")
    --     self.updateFlag = false
    -- end

    -- self.assetsManager:registerScriptHandler(testf)    

    -- if self.assetsManager:checkUpdate() then
    --     self.assetsManager:update()
    -- end
    
    self.handler = 
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()
    self.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)
    self.layer:setTouchEnabled(true)
    
    -- local ly = require("IntroLayer").new():addTo(self)
    -- self:removeAllNodeEventListeners()
end

function BenchmarkScene:onExit()
    print("----BenchmarkScene:onExit")
    self:removeAllNodeEventListeners()
end

return BenchmarkScene
