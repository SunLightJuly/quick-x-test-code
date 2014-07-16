
local BenchmarkScene = class("BenchmarkScene", function()
    return display.newScene("BenchmarkScene")
end)

local random = math.random

function BenchmarkScene:ctor()
    self.layer = display.newNode()
    self.layer:setContentSize(cc.size(display.width, display.height))
    self:addChild(self.layer)

    local button = display.newSprite("#AddCoinButton.png", display.right - 100, display.bottom + 270)
    self:addChild(button)
    self.addCoinButtonBoundingBox = button:getBoundingBox()

    local button = display.newSprite("#RemoveCoinButton.png", display.right - 100, display.bottom + 100)
    self:addChild(button)
    self.removeCoinButtonBoundingBox = button:getBoundingBox()

    cc.ui.UIPushButton.new({normal = "#ExitButton.png"})
        :onButtonClicked(function()
            game.exit()
        end)
        :pos(display.right - 100, display.top - 100)
        :addTo(self)

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
end

function BenchmarkScene:onTouch(event, x, y)
    if event == "began" then
        local p = cc.p(x, y)
        if cc.rectContainsPoint(self.addCoinButtonBoundingBox, p) then
            self.state = "ADD"
        elseif cc.rectContainsPoint(self.removeCoinButtonBoundingBox, p) then
            self.state = "REMOVE"
        else
            self.state = "IDLE"
        end
        return true
    elseif event ~= "moved" then
        self.state = "IDLE"
    end
end

-- local pt = cc.Vec2:new()

function BenchmarkScene:addCoin()
    local coin = display.newSprite("#CoinSpin01.png")
    coin:playAnimationForever(display.getAnimationCache("Coin"))
    coin:setPosition(random(self.left, self.right), random(self.bottom, self.top))
    -- self.batch:addChild(coin)
    self:addChild(coin)

    function coin:onEnterFrame(dt)
        local x, y = self:getPosition()
        x = x + random(-2, 2)
        y = y + random(-2, 2)
        self:setPosition(x, y)
        -- local pt = {x=x, y=y}
        -- pt:set(x,y)
        -- self:setPosition(pt)
    end

    self.coins[#self.coins + 1] = coin
    self.coinsCount = #self.coins
    self.label:setString(string.format("%05d", self.coinsCount))
end

function BenchmarkScene:removeCoin()
    local coin = self.coins[self.coinsCount]
    coin:removeFromParent()
    table.remove(self.coins, self.coinsCount)
    self.coinsCount = self.coinsCount - 1
    self.label:setString(string.format("%05d", self.coinsCount))
end

function BenchmarkScene:onEnterFrame(dt)
    if self.state == "ADD" then
        self:addCoin()
    elseif self.state == "REMOVE" and self.coinsCount > 0 then
        self:removeCoin()
    end

    local coins = self.coins
    -- self.prevNumCoins = self.prevNumCoins or 0
    -- if self.prevNumCoins~=#coins then
    --     self.prevNumCoins = #coins
    --     self.trackTimes = 0
    -- end
    -- local socket = require "socket"
    -- self.trackStart = socket.gettime()
    for i = 1, #coins do
        local coin = coins[i]
        coin:onEnterFrame(dt)
    end
    -- self.trackEnd = socket.gettime()
    -- if self.trackTimes then
    --     print("=========================")
    --     print("----coins num:", self.prevNumCoins)
    --     local ts = self.trackStart*1000
    --     print("----time start:", ts)
    --     local te = self.trackEnd*1000
    --     print("----time end:", te)
    --     print("----time used:", te-ts)
    --     self.trackTimes = self.trackTimes+1
    --     if self.trackTimes>=3 then self.trackTimes=nil end
    -- end
    if self.trackFlag==nil and coins[1] then
        local c = coins[1]
        local pt = cc.Vec2:new(0,0)
        local socket = require "socket"
        self.trackStart = socket.gettime()
        for i = 1, 100000 do
            c:setPosition(pt)
        end
        self.trackEnd = socket.gettime()
        print("=========================")
        local ts = self.trackStart*1000
        print("----time start:", ts)
        local te = self.trackEnd*1000
        print("----time end:", te)
        print("----time used:", te-ts)
        self.trackFlag = 1
    end
end

function BenchmarkScene:onEnter()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self.layer:setTouchEnabled(true)
    self.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)
end

return BenchmarkScene
