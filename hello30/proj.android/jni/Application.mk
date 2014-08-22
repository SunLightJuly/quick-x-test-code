APP_STL := gnustl_static
APP_CPPFLAGS := -frtti -std=c++11 -Wno-literal-suffix -fsigned-char -Os $(CPPFLAGS)

APP_DEBUG := $(strip $(NDK_DEBUG))
ifeq ($(APP_DEBUG),1)
  APP_CPPFLAGS += -DCOCOS2D_DEBUG=1
  APP_OPTIM := debug
else
  APP_CPPFLAGS += -DNDEBUG
  APP_OPTIM := release
endif

#ifeq ($(ANYSDK_DEFINE),1)
#  APP_CPPFLAGS += -DANYSDK_DEFINE=1
#  ANYSDK_DEFINE := 1
#endif

APP_ABI := armeabi
APP_PLATFORM := android-14
NDK_TOOLCHAIN_VERSION = 4.8

QUICK_CURL_ENABLED := 0
APP_CPPFLAGS += -DQUICK_CURL_ENABLED=0

QUICK_TIFF_ENABLED := 0
APP_CPPFLAGS += -DQUICK_TIFF_ENABLED=0

QUICK_WEBP_ENABLED := 0
APP_CPPFLAGS += -DQUICK_WEBP_ENABLED=0

QUICK_TGA_ENABLED := 0
APP_CPPFLAGS += -DQUICK_TGA_ENABLED=0

QUICK_PHYSICS_ENABLED := 0
APP_CPPFLAGS += -DQUICK_PHYSICS_ENABLED=0

QUICK_WEBSOCKET_ENABLED := 0
APP_CPPFLAGS += -DQUICK_WEBSOCKET_ENABLED=0

QUICK_JSON_ENABLED := 0
APP_CPPFLAGS += -DQUICK_JSON_ENABLED=0
APP_CFLAGS += -DQUICK_JSON_ENABLED=0

QUICK_SQLITE_ENABLED := 0
APP_CPPFLAGS += -DQUICK_SQLITE_ENABLED=0
APP_CFLAGS += -DQUICK_SQLITE_ENABLED=0

QUICK_CCS_ARMATURE_ENABLED := 0
APP_CPPFLAGS += -DQUICK_CCS_ARMATURE_ENABLED=0

QUICK_EXTRA_FILTERS_ENABLED := 0
APP_CPPFLAGS += -DQUICK_EXTRA_FILTERS_ENABLED=0

ifeq ($(QUICK_PHYSICS_ENABLED),1)
APP_CPPFLAGS += -DCC_USE_PHYSICS=1
else
APP_CPPFLAGS += -DCC_USE_PHYSICS=0
endif