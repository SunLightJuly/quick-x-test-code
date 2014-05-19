
function CClass(classname)
	-- check if classname has been declared
	ALL_CCLASS_REG = ALL_CCLASS_REG or {}
	local mt = ALL_CCLASS_REG[classname]
	if (mt~=nil) then return end

	dump(QUICKX_CCLASS_REG_FUNC)

	mt = {}
	mt.__index, err = lua_binder.load(classname, {})
	if (mt.__index==nil) then
		print("CClass Error: "..err)
		-- return
	end
	dump(mt.__index)

	local cls = {}
	setmetatable(cls, mt)
	rawset(_G, classname, cls)
	dump(_G[classname])

	ALL_CCLASS_REG[classname] = mt
end