--
-- actions/vstudio/vs2015.lua
-- Extend the existing exporters with support for Visual Studio 2015.
-- Copyright (c) 2015-2015 Jason Perkins and the Premake project
--
	premake.vstudio.vc2015 = {}
	local vc2015 = premake.vstudio.vc2015
	local vstudio = premake.vstudio


---
-- Define the Visual Studio 2015 export action.
---

	newaction {
		-- Metadata for the command line and help system

		trigger     = "vs2015",
		shortname   = "Visual Studio 2015",
		description = "Generate Visual Studio 2015 project files",

		-- Visual Studio always uses Windows path and naming conventions

		os = "windows",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Makefile", "None", "Utility" },
		valid_languages = { "C", "C++", "C#" },
		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		-- Workspace and project generation logic

		onsolution = function(sln)
			premake.generate(sln, "%%.sln", vstudio.sln2005.generate)
		end,

		onproject = function(prj)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, "%%.csproj", vstudio.cs2005.generate)
				premake.generate(prj, "%%.csproj.user", vstudio.cs2005.generate_user)
			else
			premake.generate(prj, "%%.vcxproj", premake.vs2010_vcxproj)
			premake.generate(prj, "%%.vcxproj.user", premake.vs2010_vcxproj_user)
			premake.generate(prj, "%%.vcxproj.filters", vstudio.vc2010.generate_filters)
			end
		end,


		oncleansolution = premake.vstudio.cleansolution,
		oncleanproject  = premake.vstudio.cleanproject,
		oncleantarget   = premake.vstudio.cleantarget,

		-- This stuff is specific to the Visual Studio exporters

		vstudio = {
			solutionVersion = "14",
			versionName     = "2015",
			targetFramework = "4.5",
			toolsVersion    = "14.0",
			filterToolsVersion = "4.0",
			platformToolset = "v140"
		}
	}
