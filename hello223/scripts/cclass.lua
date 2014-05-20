function cclass(classname, namespace, aliasname)
	-- check namespace
	if type(namespace)~="table" then
		print("namespace error!")
		return
	end

	-- check if classname has been declared
	if namespace[classname] then
		print("CClass "..classname.." registered")
		return
	end

	-- load cclass
	mt, err = lua_binder.load(classname)
	if (mt==nil) then
		print("CClass Error: "..err)
		return
	end
	dump(mt)

	-- set namespace
	mt.namespace_ = namespace

	-- set __index
	mt.__index = function ( target, name )
		-- find function in metatable
		local mt_ = getmetatable(target)
		if mt_[name] then
			if mt_[name].retType==0 then
				return function ( self, ... )
					mt_[name].cfunc(...)
					return self
				end
			else 
				return mt_[name].cfunc
			end
		end

		-- find function in super classes
		for i,v in ipairs(mt_.cclass_super) do
			local super_ = mt.namespace_[v]
			if super_[name] then
				return super_[name]
			end
		end
	end

	local cls = {}
	setmetatable(cls, mt)
	namespace[classname] = cls
	if aliasname then 
		namespace[aliasname] = cls
	end
end

local function CClass(classname, namespace)
	-- check if classname has been declared
	local nsn = namespace.cclass_namespace_name
	if namespace[classname] then
		print("CClass "..nsn.."."..classname.." registered")
		return
	end
	print("start register: "..nsn.."."..classname)
	-- ALL_CCLASS_REG = ALL_CCLASS_REG or {}
	-- local mt = ALL_CCLASS_REG[classname]
	-- if (mt~=nil) then return end

	-- dump(QUICKX_CCLASS_REG_FUNC)

	-- mt = {}
	mt, err = lua_binder.load(classname)
	if (mt==nil) then
		print("CClass Error: "..err)
		-- return
		mt = {}
	end
	mt.namespace_string = namespace.cclass_namespace_name
	dump(mt)

	mt.__index = function ( target, name )
		local mt_ = getmetatable(target)
		if mt_[name] then
			return mt_[name].cfunc
		end

		for i,v in ipairs(mt_.cclass_super) do
			print("####v = "..v)
			local ns = _G[mt.namespace_string]
			local super_ = ns[v]
			if super_[name] then
				return super_[name]
			end
		end
	end

	local cls = {}
	setmetatable(cls, mt)
	-- rawset(_G, classname, cls)
	-- dump(_G[classname])
	namespace[classname] = cls

	-- ALL_CCLASS_REG[classname] = mt
end

function CClassNameSpace( name )
	if type(_G[name])=="table" then
		return
	end

	local mt = {}
	mt.cclass_namespace_name = name
	mt.__index = function ( target, k )
		local mt_ = getmetatable(target)
		if mt_[k] then return mt_[k] end
		CClass(k, mt_)
		return mt_[k]
	end

	local ns = {}
	-- ns.cclass_namespace_name = "ns_"..name
	setmetatable(ns, mt)
	rawset(_G, name, ns)
end

