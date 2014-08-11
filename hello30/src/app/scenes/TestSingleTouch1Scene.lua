
import("..includes.functions")

local TestSingleTouch1Scene = class("TestSingleTouch1Scene", function()
    return display.newScene("TestSingleTouch1Scene")
end)

local scheduler = require("framework.scheduler")

function TestSingleTouch1Scene:ctor()
    -- createTouchableSprite() 定义在 includes/functions.lua 中
    self.sprite = createTouchableSprite({
            image = "WhiteButton.png",
            size = cc.size(500, 300),
            label = "TOUCH ME !",
            labelColor = cc.c3b(255, 0, 0)})
        :pos(display.cx, display.cy)
        :addTo(self)
    drawBoundingBox(self, self.sprite, cc.c4f(0, 1.0, 0, 1.0))

    -- 启用触摸
    self.sprite:setTouchEnabled(true)
    -- 添加触摸事件处理函数
    self.sprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        -- event.name 是触摸事件的状态：began, moved, ended, cancelled
        -- event.x, event.y 是触摸点当前位置
        -- event.prevX, event.prevY 是触摸点之前的位置
        local label = string.format("sprite: %s x,y: %0.2f, %0.2f", event.name, event.x, event.y)
        self.sprite.label:setString(label)

        -- 返回 true 表示要响应该触摸事件，并继续接收该触摸事件的状态变化
        return true
    end)

    --

    app:createNextButton(self)
    app:createTitle(self, "单点触摸测试 - 响应触摸事件")
end

function TestSingleTouch1Scene:onEnter()
    -- if device.platform == "android" then
        -- avoid unmeant back
        self:performWithDelay(function()
            -- keypad layer, for android
            local layer = display.newLayer()
            layer:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
                print("*******NodeEventListener*******")
                dump(event)
                -- if event.key == "back" then
                --   app.exit()
                -- end
            end)
            self:addChild(layer)

            layer:setKeypadEnabled(true)
            layer:setTouchEnabled(false)
        end, 0.5)
    -- end

    -- local ts = crypto.md5("ksdjflkasdjflsjfdlasdjfl")
    -- print("*******ts = ", ts)
    -- local dt = cc.HelperFunc:getFileData("ttttt")

    display.newDrawNode():drawCircle(100, {fillColor = cc.c4f(0,0,1,1), pos = {display.cx, display.cy}}):addTo(self)
    display.newDrawNode():drawRect({display.cx, display.cy, 100, 100}, {fillColor = cc.c4f(1,0,0,1)}):addTo(self)
    display.newDrawNode():drawDot(cc.p(display.cx, display.cy), 10, cc.c4f(0,1,0,1)):addTo(self)
    display.newDrawNode():drawLine({0,0}, {200,200}, 5, cc.c4f(1,1,0,1)):addTo(self)

    -- local function autogc()
    --     if self.node then
    --         print("----remove node")
    --         self.node = nil
    --     else
    --         print("----new node")
    --         self.node = display.newNode()
    --     end
    --     print("----autogc")
    --     collectgarbage("collect")
    --     scheduler.performWithDelayGlobal(autogc, 0.5)
    -- end
    -- scheduler.performWithDelayGlobal(autogc, 0.5)

    print("----46/60", math.floor(46/60))
end

return TestSingleTouch1Scene
