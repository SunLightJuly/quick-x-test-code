local IntroLayer = class("IntroLayer", function()
    return display.newLayer()
end)
 
function IntroLayer:ctor()
    printInfo("IntroLayer:ctor")
 
    local button = cc.ui.UIPushButton.new("#ExitButton.png")
    button:pos(display.cx, 100)
    button:onButtonPressed(function(event)
        event.target:setScale(1.1)
    end)
    button:onButtonRelease(function(event)
        event.target:setScale(1.0)
    end)
    button:onButtonClicked(function(event)
        self:removeSelf()
    end)
    self:addChild(button)
 
    -- Node事件
    self:setNodeEventEnabled(true)
end
 
function IntroLayer:onEnter()
    printInfo("IntroLayer:onEnter")
end
 
function IntroLayer:onExit()
    printInfo("IntroLayer:onExit")
    self:removeAllNodeEventListeners()   -- 增加这一句出错
end

return IntroLayer