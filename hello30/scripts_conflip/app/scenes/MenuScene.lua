
local AdBar = import("..views.AdBar")
local BubbleButton = import("..views.BubbleButton")

local MenuScene = class("MenuScene", function()
    return display.newScene("MenuScene")
end)

function MenuScene:ctor()
    self.bg = display.newSprite("#MenuSceneBg.png", display.cx, display.cy)
    self:addChild(self.bg)

    self.adBar = AdBar.new()
    self:addChild(self.adBar)

    self.moreGamesButton = BubbleButton.new({
            image = "#MenuSceneMoreGamesButton.png",
            sound = GAME_SFX.tapButton,
            prepare = function()
                audio.playSound(GAME_SFX.tapButton)
                self.moreGamesButton:setButtonEnabled(false)
            end,
            listener = function()
                app:enterMoreGamesScene()
            end,
        })
        :align(display.CENTER, display.left + 150, display.bottom + 300)
        :addTo(self)

    self.startButton = BubbleButton.new({
            image = "#MenuSceneStartButton.png",
            sound = GAME_SFX.tapButton,
            prepare = function()
                audio.playSound(GAME_SFX.tapButton)
                self.startButton:setButtonEnabled(false)
            end,
            listener = function()
                app:enterChooseLevelScene()
            end,
        })
        :align(display.CENTER, display.right - 150, display.bottom + 300)
        :addTo(self)

end

function MenuScene:onEnterFrame(dt)
    self.nf = self.nf or 0
    self.nf = self.nf+1
    if self.nf<5 then print("MenuScene:onEnterFrame", self.nf, dt) end
end

function MenuScene:onEnter()
    print("---------MenuScene:onEnter")
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
end

return MenuScene
