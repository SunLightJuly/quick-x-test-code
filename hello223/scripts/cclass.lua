
local function getArrayType( c )
	if c=="C" then
		return type("")
	else
		return "userdata"
	end
end

local function getRetType( typeString )
	if not typeString then
		return
	end

	local c = string.sub(typeString, 1, 1)
	if c=="[" then
		return getArrayType( string.sub(typeString, 2, 2) )
	elseif c=="Z" then
		return type(true)
	elseif c=="I" then
		return type(1)
	elseif c=="F" then
		return type(1.0)
	end

	return "cclass", string.sub(typeString, 2, -2)
end

local function wrapObj(udata, mt)
	local obj = {}
	obj.udata_ = udata
	setmetatable(obj, mt)
	return obj
end

local function convert_args( args, types )
	dump(args)
	local args_new = {nil}
	if type(types)~="table" then return args_new end

	local n
	local typeWant
	local typeCur
	for i,v in ipairs(types) do
		n = i
		typeCur = cclass_type_name(args[i])
		typeWant = v
		if not cclass_type_compare( typeCur, typeWant, cc ) then 
			break 
		end
		if type(args[i])~=typeCur then
			if not args[i].udata_ then 
				typeCur = type(args[i])
				break
			end
			args[i] = args[i].udata_
		end
	end	

	dump(args)
	if typeCur==typeWant then return args end

	print("[CCLASS ERR] bad argument #"..n.."("..typeWant.." expected, got "..typeCur)
end

local function split_sign_string( str )
	if not str or string.len(str)<1 then return true end
	local args = string.split(str, '|')
	dump(args)
	for i,v in ipairs(args) do
		if v=='F' or v=='I' or v=='J' then 
			args[i] = type(1) 
		elseif v=='T' then
			args[i] = type("")
		elseif v=='Z' then 
			args[i] = type(true)
		end
	end
	dump(args)
	return args
end

local function call_cfunction_evt( mt, evt, evtname, ... )
	print("call_cfunction_evt--------->")
	dump(evt)
	if not evt.mothodParamsType then
		evt.mothodParamsType = split_sign_string(evt.methodSign)
	end

	local args = convert_args( {...}, evt.mothodParamsType )
	if not args then
		print("[CCLASS ERR] Error in "..mt.classname_..":"..evtname)
		return
	end
	dump(args)

	local retType = getRetType(evt.retType)
	-- return void
	if not retType then
		evt.cfunc(unpack(args))
		return
	-- return c-object
	elseif retType=="cclass" then
		local udata = evt.cfunc(unpack(args))
		return wrapObj(udata, mt)
	end

	-- return normal
	return evt.cfunc(unpack(args))
end

local function cclass_mt_index( target, keyname )
		-- find function in metatable
		local mt_ = getmetatable(target)
		local evt = mt_[keyname]
		if evt then
			if type(evt)~="table" or not evt.cfunc then
				return evt
			end

			local function evt_func( ... )
				return call_cfunction_evt(mt_, evt, keyname, ...)
			end

			return evt_func
		end

		-- find function in super classes
		for i,v in ipairs(mt_.cclass_super) do
			local super_ = mt_.namespace_[v]
			if super_[keyname] then
				return super_[keyname]
			end
		end
end

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
	local mt, err = lua_binder.load(classname)
	if (mt==nil) then
		print("CClass Error: "..err)
		return
	end

	-- set namespace
	mt.namespace_ = namespace
	-- set classname
	mt.classname_ = classname

	-- set __index
	mt.__index = cclass_mt_index

	-- dump(mt)
	local cls = {}
	setmetatable(cls, mt)
	namespace[classname] = cls
	if aliasname then 
		namespace[aliasname] = cls
	end
end

function cclass_type_compare( cur, want, ns )
	if cur==want then return true end

	return false
end

function cclass_type_name( obj )
	local t = type(obj)
	print("cclass_type_name: t= "..t)
	if t~="table" and t~="userdata" then return t end
	local mt = getmetatable(obj)
	print(mt)
	print(mt.classname_)
	if mt and mt.classname_ then
		return mt.classname_
	else
		return t
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
	local mt, err = lua_binder.load(classname)
	if (mt==nil) then
		print("CClass Error: "..err)
		-- return
		mt = {}
	end
	mt.namespace_string = namespace.cclass_namespace_name
	dump(mt)

	mt.__index = cclass_mt_index

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

