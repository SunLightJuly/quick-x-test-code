print("==============================test ffi")

local ffi = require("ffi")

print("==============================test ffi 1", ffi)

ffi.cdef[[
//int luabinderload(const char * classname);
void test_add_xy(int x, int y);
int printf(const char*, ...);

typedef void (*Func1) (int, int);

//Func1 f = test_add_xy;
//Func1 funcs[] = {test_add_xy, NULL};
]]

print("==============================test ffi 2", ffi)

local rni = ffi.C.printf("Hello %s!\n", "world")
print("rni···:", rni)
-- local rni = ffi.C.luabinderload("CCNodeTest")
-- rni = ffi.C.test_add_xy(26, 24)
-- rni = f(26, 24)
-- rni = ffi.C.funcs[1](26, 24)
-- print("rni···:", rni)

return ffi
