local lualibname = "lua54"
local luacname = "luac"
local sln_name = "ltokenp"
local obj_path =  "../build/obj/%{wks.name}/%{prj.name}/%{cfg.platform}/%{cfg.buildcfg}"

solution(sln_name)
	configurations { "DLL Debug", "DLL Release", "Static Debug", "Static Release" }
	platforms { "x32", "x64" }
  location ("../sln/".. sln_name)
  targetdir "bin"

project "lualib"
	language    "C"
	filter {"configurations:*DLL*"}
		kind       ( "SharedLib" )
		targetname	( lualibname )
		
	
	filter {"configurations:*Static*"}
		kind        "StaticLib"
		targetname	( lualibname .. "s" )
		
	filter {"configurations:DLL Debug"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		implibdir ("../bin/%{cfg.platform}/%{cfg.buildcfg}/libd")
	filter {"configurations:DLL Release"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		implibdir ("../bin/%{cfg.platform}/%{cfg.buildcfg}/lib")
	filter {"configurations:Static Debug"}
		implibdir ("../bin/%{cfg.platform}/%{cfg.buildcfg}/libd")
	filter {"configurations:Static Release"}
		implibdir ("../bin/%{cfg.platform}/%{cfg.buildcfg}/lib")

	filter{ }
		includedirs { "src" }
		objdir	( obj_path)
		
	files
	{
		"./src/**.h",
		"./src/**.c"
	}

	excludes
	{
		"src/lua.c",
		"src/luac.c",
		"src/print.c",
		"**.lua",
		"etc/*.c"
	}

	vpaths {
	   ["Headers"] = "**.h",
	   ["Sources/*"] = {"**.c", "**.cpp"},
	   ["Docs"] = "**.txt"
	}
	
	filter{"configurations:*Debug*"}
		defines { "_DEBUG",	}
		buildoptions { "/DEBUG" }
		defines { "_WIN32" }
		symbols "On"
	filter{"configurations:*Release*"}
		defines { "_WIN32" }
		symbols "On"
	
	 filter {"platforms:x64"}
		architecture "x64"
	 filter {"platforms:x32"}
		architecture "x32"

	filter{"configurations:*Debug*"}
		runtime("Debug")
	filter{"configurations:*Release*"}
		runtime("Release")
	
	
	 filter{"configurations:*DLL*", "system:windows"}
			defines { "LUA_BUILD_AS_DLL" }

	filter "system:linux or bsd or hurd or aix"
		defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }

	filter "system:macosx"
		defines     { "LUA_USE_MACOSX" }

project "lua"
		targetname  ("lua")
		language    "C"
		kind        "ConsoleApp"

		files
		{
			"src/lua.c",  
			"src/lua.h",  
			"src/luaconf.h",  
			"src/lauxlib.h",  
			"src/lualib.h",
		}
	vpaths {
	   ["Headers"] = "**.h",
	   ["Sources/*"] = {"**.c", "**.cpp"},
	   ["Docs"] = "**.txt"
	}

	filter{"configurations:*Debug*"}
		defines { "_DEBUG",	}
		buildoptions { "/DEBUG" }
		defines { "_WIN32" }
		symbols "On"
	filter{"configurations:*Release*"}
		defines { "_WIN32" }
		symbols "On"
		
	filter{"configurations:*Debug*"}
		runtime("Debug")
	filter{"configurations:*Release*"}
		runtime("Release")
	
	 filter {"platforms:x64"}
		architecture "x64"
	 filter {"platforms:x32"}
		architecture "x32"
	


	filter {"configurations:DLL Debug"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		libdirs ("../bin/%{cfg.platform}/%{cfg.buildcfg}/libd")
	filter {"configurations:DLL Release"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		libdirs ("../bin/%{cfg.platform}/%{cfg.buildcfg}/lib")
	filter {"configurations:Static Debug"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		libdirs ("../bin/%{cfg.platform}/%{cfg.buildcfg}/libd")
	filter {"configurations:Static Release"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		libdirs ("../bin/%{cfg.platform}/%{cfg.buildcfg}/lib")

	filter{"configurations:*DLL*", "system:windows"}
			defines { "LUA_BUILD_AS_DLL" }

	filter {"configurations:*DLL*"}
		links { lualibname }
	filter {"configurations:*Static*"}
		links { lualibname.."s" }

        
project "luac"
		targetname  (luacname)
		language    "C"
		kind        "ConsoleApp"
		includedirs { "src" }
	
	filter {}
		objdir	( obj_path)

   files { "src/*.h", "src/*.c" }
   removefiles { "src/lua.c" }
	vpaths {
	   ["Headers"] = "**.h",
	   ["Sources/*"] = {"**.c", "**.cpp"},
	   ["Docs"] = "**.txt"
	}

	filter{"configurations:*Debug*"}
		defines { "_DEBUG",	}
		buildoptions { "/DEBUG" }
		defines { "_WIN32" }
		symbols "On"

	filter{"configurations:*Release*"}
		defines { "_WIN32" }
		symbols "On"

	filter{"configurations:*Debug*"}
		runtime("Debug")
	filter{"configurations:*Release*"}
		runtime("Release")
	
	filter{"configurations:*Static*"}
		flags { "StaticRuntime" } 

	filter {"platforms:x64"}
		architecture "x64"
	filter {"platforms:x32"}
		architecture "x32"


	filter {"configurations:DLL Debug"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		libdirs ("../bin/%{cfg.platform}/%{cfg.buildcfg}/libd")
	filter {"configurations:DLL Release"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		libdirs ("../bin/%{cfg.platform}/%{cfg.buildcfg}/lib")
	filter {"configurations:Static Debug"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		libdirs ("../bin/%{cfg.platform}/%{cfg.buildcfg}/libd")
	filter {"configurations:Static Release"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		libdirs ("../bin/%{cfg.platform}/%{cfg.buildcfg}/lib")
project "ltokenp"
		targetname  (ltokenp)
		language    "C"
		kind        "ConsoleApp"
		includedirs("src")

	files
	{
		"./src/**.h",
		"./src/**.c"
	}

		files
		{
			"ltokenp.c",
		}
			excludes
	{
		"src/lua.c",
		"src/luac.c",
		"src/print.c",
		"**.lua",
		"etc/*.c"
	}

	vpaths {
	   ["Headers"] = "**.h",
	   ["Sources/*"] = {"**.c", "**.cpp"},
	   ["Docs"] = "**.txt"
	}

	filter{"configurations:*Debug*"}
		defines { "_DEBUG",	}
		buildoptions { "/DEBUG" }
		defines { "_WIN32","LTOKENP_T" }
		symbols "On"
	filter{"configurations:*Release*"}
		defines { "_WIN32","LTOKENP_T" }
		symbols "On"
		
	filter{"configurations:*Debug*"}
		runtime("Debug")
	filter{"configurations:*Release*"}
		runtime("Release")
	
	 filter {"platforms:x64"}
		architecture "x64"
	 filter {"platforms:x32"}
		architecture "x32"
	


	filter {"configurations:DLL Debug"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		libdirs ("../bin/%{cfg.platform}/%{cfg.buildcfg}/libd")
	filter {"configurations:DLL Release"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		libdirs ("../bin/%{cfg.platform}/%{cfg.buildcfg}/lib")
	filter {"configurations:Static Debug"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		libdirs ("../bin/%{cfg.platform}/%{cfg.buildcfg}/libd")
	filter {"configurations:Static Release"}
		targetdir("../bin/%{cfg.platform}/%{cfg.buildcfg}")
		libdirs ("../bin/%{cfg.platform}/%{cfg.buildcfg}/lib")

	filter{"configurations:*DLL*", "system:windows"}
			defines { "LUA_BUILD_AS_DLL" }

--	filter {"configurations:*DLL*"}
--		links { lualibname }
		