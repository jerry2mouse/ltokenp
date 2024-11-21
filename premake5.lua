--premake
-- fmt-premake 按premake格式化标志
local lualibname = "lua54"
local luacname = "luac"
local sln_name = "ltokenp"

local obj_path = "../obj/" .. sln_name .. "/%{cfg.platform}_%{cfg.buildcfg}"
solution(sln_name)
    configurations{ "Debug", "Release" }
    platforms{ "x64", "x32" }
    location("../sln/" .. sln_name)
    targetdir "bin"


project "ltokenp"
    targetname(ltokenp)
    language "C"
    kind "ConsoleApp"
    includedirs("src")
    includedirs("./")

    files
    {
        "./src/**.h",
        "./src/**.c"
    }

    files
    {
        "ltokenp.c",
        "ltokenp.h",
    }
    excludes
    {
        "src/lua.c",
        "src/luac.c",
        "src/print.c",
        "**.lua",
        "etc/*.c"
    }

    vpaths{
        ["Headers"] = "**.h",
        ["Sources/*"] = { "**.c", "**.cpp" },
        ["Docs"] = "**.txt"
    }

    filter{ "configurations:*Debug*" }
        defines{ "_DEBUG", }
        defines{ "LTOKENP_T" }
        symbols "On"
    filter{ "configurations:*Release*" }
        defines{ "LTOKENP_T" }
        symbols "On"

    filter{ "configurations:*Debug*" }
        runtime("Debug")
    filter{ "configurations:*Release*" }
        runtime("Release")

    filter{ "platforms:x64" }
        architecture "x64"
    filter{ "platforms:x32" }
        architecture "x32"

    filter "system:linux or bsd or hurd"
        defines{ "LUA_USE_POSIX", "LUA_USE_DLOPEN" }
        links{ "m" }
        linkoptions{ "-rdynamic" }

    filter "system:linux or hurd"
        links{ "dl", "rt" }

    filter{ "configurations:Debug" }
        targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
        libdirs("../bin/%{cfg.platform}/%{cfg.buildcfg}/libd")
    filter{ "configurations:Release" }
        targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
        libdirs("../bin/%{cfg.platform}/%{cfg.buildcfg}/lib")


