//
//  testdylib.c
//  testdylib
//
//  Created by ZhuJunfeng on 14-5-28.
//  Copyright (c) 2014年 ZhuJunfeng. All rights reserved.
//

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include <stdio.h>
#include <math.h>

static int l_sin (lua_State *L) {
    double d = lua_tonumber(L, 1);  /* get argument */
    printf("--------entry testdylib.sin()\n");
    lua_pushnumber(L, sin(d));      /* push result */
    return 1;                       /* number of results */
}

static const struct luaL_reg mylib [] = {
    {"sin", l_sin},
    {NULL, NULL}  /* sentinel */
};

int luaopen_testdylib (lua_State *L) {
    luaL_openlib(L, "testdylib", mylib, 0);
    return 1;
}