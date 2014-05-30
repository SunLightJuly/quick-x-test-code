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

function MainScene:ctor()
	-- test get symbol
	local sym, err
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
	print("data len: "..string.len(data))
	func = package.loadlib(libpath, "luaopen_testdylib")
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

    ui.newTTFLabel({text = "Hello, 世界\n"..sinx, size = 64, align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx, display.cy)
        :addTo(self)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
