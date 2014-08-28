-- require("fflua_test")
-- require("ffi_test")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

--test cclass
--[[
require("cclass")
CClassNameSpace("ccx")

cclass("CCNodeTest", cc, "NodeTest")
cclass("CCSpriteTest", cc, "SpriteTest")

function cc.SpriteTest:new(...)
	return self.create(...)
end
]]

-- local oldfunc = CCNode.setPosition

-- cc.Sprite:setPosition(101, 101)

-- function tolua.getcfunction( class, key )
-- 	if class[key..'_C__'] then
-- 		return class[key..'_C__']
-- 	end

-- 	return class[key]
-- end

print("----···")
cc.Node.xxxx = {}
print("============···")


-- print("----define CCNode:setPosition")
-- function CCNode:setPosition(x, y)
-- end

-- print("----define CCSprite:setPosition")
-- function CCSprite:setPosition(x, y)
-- end

-- print("----define end")


function CCNode:setPosition(x, y)
	print("----CCNode:setPosition("..x..","..y..")")
	local func = tolua.getcfunction(self, "setPosition")
	if func then return func(self, x, y) end
end

function CCLabelTTF:setPosition(x, y)
	print("----CCLabelTTF:setPosition("..x..","..y..")")
	local func = tolua.getcfunction(self, "setPosition")
	if func then return func(self, x, y) end
end

function tolua.resetcfunction(cls, methodname)
	local func = tolua.getcfunction(cls, methodname)
	if func then cls[methodname] = func end
end

function MainScene:ctor()

    self.layer = display.newLayer()
    self:addChild(self.layer)

	self.img = display.newNode()
	self:addChild(self.img)

	-- tolua.resetcfunction( CCNode, "setPosition" )

	-- local sprite = cc.Sprite:create("helloworld.png")
	-- print("----sprite:setPosition---- class="..tolua.type(sprite))
	-- sprite:setPosition(display.cx, display.cy)
	-- self:addChild(sprite)


	-- test get symbol
	local sym, err
	if lua_binder then
		if lua_binder.opensym then
			err = lua_binder.opensym()
			if not err then
				sym, err = lua_binder.getsym("printf")
				if sym then
					-- sym()
					-- NodeTest:create()
				else
					print("========getsym err："..err)
				end
				lua_binder.closesym()
			else
					print("========opensym err："..err)
			end
		end
	end


	-- test dylib
	-- print("============================="..device.writablePath)
	local libpath,func
	if device.platform=='mac' then
		libpath = "libtestdylib.dylib"
	else
		libpath = device.writablePath.."libtestdylib.so"
		-- libpath = "/sdcard/testdylib.so"
	end
	print("loadlib: "..libpath)
	local data = CCFileUtils:sharedFileUtils():getFileData(libpath)
	if data then
		print("data len: "..string.len(data))
		func = package.loadlib(libpath, "luaopen_testdylib")
	end
	if func then
		func()
		sinx = testdylib.sin(2.0)
	else
		sinx = "Error"
	end
	-- local sinx = "sinx"
	print(sinx)

	--test cclass
	--[[
	local x

	local node = cc.Node:create()
	x = os.clock()
	for i=1,1000000 do
		node:setPosition(100, 100)
	end
	print(string.format("elapsed time 1: %.2f\n", os.clock() - x))

	local node_t = cc.NodeTest:create()
	x = os.clock()
	for i=1,1000000 do
		node_t:setPosition(100, 100)
	end
	print(string.format("elapsed time 2: %.2f\n", os.clock() - x))

	local sprite = cc.Sprite:create("helloworld.png")
	x = os.clock()
	for i=1,1000000 do
		sprite:setPosition(100, 100)
	end
	print(string.format("elapsed time 3: %.2f\n", os.clock() - x))

	local sp = cc.SpriteTest:new("helloworld.png")
	x = os.clock()
	for i=1,1000000 do
		sp:setPosition(100, 100)
	end
	print(string.format("elapsed time 4: %.2f\n", os.clock() - x))

	-- dump(sp)
	sp.testValue = 10101010101
	-- dump(getmetatable(sp))
	print("####cclass_type_name: "..cclass_type_name(sp))
	-- print(sp.udata_)
	print(sp:setPosition(10, 10).test("test sp:test!!! --- ")..sp.testValue)
	print(cc.SpriteTest.test("test cc.spritetest!!!"))

	-- print(ccx.CCSpriteTest.test("test sprite!!!"))
	-- print(ccx.CCNodeTest.test("test string!!!"))
	-- print(ccx.CCNodeTest.test("test string again!!!"))
	]]

	local lbl = 
    ui.newTTFLabel({text = "Hello, 世界\n"..sinx, size = 64, align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx, display.cy)
        :addTo(self)

    print("lbl type: "..tolua.type(lbl))
    print("Label type: "..tolua.type(CCLabelTTF))
end

function MainScene:onTouch(event, x, y)

	print("----onTouch("..event..","..x..","..y..")")

		print('2---- self.img=')
		print(self.img)

    if event == "began" then
        local p = CCPoint(x, y)
        -- if self.addCoinButtonBoundingBox:containsPoint(p) then
        --     self.state = "ADD"
        -- elseif self.removeCoinButtonBoundingBox:containsPoint(p) then
        --     self.state = "REMOVE"
        -- else
        --     self.state = "IDLE"
        -- end
        return true
    elseif event ~= "moved" then
        self.state = "IDLE"
    end
end

function MainScene:onEnterFrame(dt)
	if not self.flag then
		print('3---- self.img=')
		print(self.img)
		self.flag = true
	end
end

function MainScene:onEnter()
	-- self.img = nil
	-- tolua.setvalue(self.img)
	-- print('s---- self.img=')
	-- print(self.img)

	print('0---- self.img=')
	print(self.img)
	self.img:removeSelf()
	print('1---- self.img=')
	print(self.img)

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()
    self.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)
    self.layer:setTouchEnabled(true)
end

function MainScene:onExit()
end

return MainScene
