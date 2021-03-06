-- android_project.lua
-- Generates Android.mk files in the jni directory

	function premake.android.project(prj)

		_p('ifndef LOCAL_PATH')
		_p('LOCAL_PATH := $(call my-dir)')
		_p('endif')
		_p('')

		_p('include $(CLEAR_VARS)')
		_p('')

		-- List the build configurations, and the settings for each
		for cfg in premake.eachconfig(prj) do
			_p(0, 'ifeq ($(config),%s)', cfg.name)
			_p('')

			_p(1, 'LOCAL_MODULE := %s', cfg.project.name)
			if prj.kind == "StaticLib" or prj.kind == "SharedLib" then
				_p(1, 'LOCAL_MODULE_FILENAME := %s%s%s', cfg.buildtarget.prefix, cfg.project.name, cfg.buildtarget.suffix)
			else
				_p(1, 'LOCAL_MODULE_FILENAME := %s', cfg.buildtarget.basename)
			end
			_p('')

			export_cflags = ""
			for _,v in ipairs(cfg.defines) do
				export_cflags = export_cflags .. " -D" .. v
			end
			export_cflags = export_cflags .. ' ' .. table.concat(cfg.buildoptions, " ")
			_p(1, "LOCAL_CFLAGS := %s", export_cflags)
			_p('')

			if cfg.flags.CPP11 then
				_p(1, "LOCAL_CPPFLAGS := -std=c++11")
				_p('')
			end
			
			-- jni has to add "../"
            include_dirs = ""
            for _,v in ipairs(cfg.includedirs) do
                local f = string.find(v,'%$%(')
				if  f == nil then 
                    include_dirs = include_dirs .. " \\\n\t\t../" .. v
                else
                    include_dirs = include_dirs .. " \\\n\t\t" .. v
                end
			end			
            _p(1, "LOCAL_C_INCLUDES := %s", include_dirs)
			_p('')
			
			src_files = ""
			for _,v in ipairs(cfg.files) do
				ext = string.lower(path.getextension(v))
				if ext == ".c" or ext == ".cpp" then
					src_files = src_files .. " \\\n\t\t../" .. v
				end
			end
			_p(1, "LOCAL_SRC_FILES := %s", src_files)
			_p('')

			--_p(1, 'Library paths: %s', table.concat(cfg.libdirs, ";"))

			local static_lib_deps = {}
			local shared_lib_deps = {}
			local deps = premake.getdependencies(prj)
			if #deps > 0 then
				for _, depprj in ipairs(deps) do
					if depprj.kind == "StaticLib" then
						table.insert(static_lib_deps, depprj.name)
					elseif depprj.kind == "SharedLib" then
						table.insert(shared_lib_deps, depprj.name)
					end
				end
			end
			
			if prj.kind ~= "StaticLib" then
                if prj.ndkmodule_sharedlinks ~= nil and #prj.ndkmodule_sharedlinks > 0 then
                    for _, module in ipairs(prj.ndkmodule_sharedlinks) do
                        table.insert(shared_lib_deps, module)
                    end			
                end
                if prj.ndkmodule_staticlinks ~= nil and #prj.ndkmodule_staticlinks > 0 then
                    for _, module in ipairs(prj.ndkmodule_staticlinks) do
                        table.insert(static_lib_deps, module)
                    end			
                end
			end

			if #static_lib_deps > 0 then
				_p(1, 'LOCAL_STATIC_LIBRARIES := \\\n\t\t%s', table.concat(static_lib_deps, " \\\n\t\t"))
				_p('')
			end
			
			if #shared_lib_deps > 0 then
				_p(1, 'LOCAL_SHARED_LIBRARIES := \\\n\t\t%s', table.concat(shared_lib_deps, " \\\n\t\t"))
				_p('')
			end

			local links = premake.getlinks(cfg, "system", "basename")
			if #links > 0 then
				_p(1, 'LOCAL_LDLIBS := \\')
				for  _, dir in ipairs(cfg.libdirs) do
					_p(2, '-L%s \\', dir)
				end
				for  _, link in ipairs(links) do
					_p(2, '-l%s \\', link)
				end
			end
			_p('')

			if #cfg.prebuildcommands > 0 then
			end

			if #cfg.prelinkcommands > 0 then
			end

			if #cfg.postbuildcommands > 0 then
			end

			_p(0, 'endif # end %s', cfg.name)
			_p('')
		end

		if prj.kind == "StaticLib" then
			_p('include $(BUILD_STATIC_LIBRARY)')
		else
			_p('include $(BUILD_SHARED_LIBRARY)')
	end

    if prj.kind ~= "StaticLib" then
        if prj.ndkmodule_imports ~= nil and #prj.ndkmodule_imports > 0 then
            for _, module in ipairs(prj.ndkmodule_imports) do
                _p('$(call import-module,%s)',module)
            end			
        end
	end	
		
end
