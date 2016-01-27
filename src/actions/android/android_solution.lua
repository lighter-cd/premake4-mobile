
function premake.android.applicationmk(sln)
	for cfg in solution.eachconfig(sln) do

		if cfg.ndkabi ~= nil then
			_p('  APP_ABI := %s', cfg.ndkabi)
		end
		if cfg.ndkplatform ~= nil then
			_p('  APP_PLATFORM := %s', cfg.ndkplatform)
		end
		if cfg.ndktoolchainversion ~= nil then
			_p('  NDK_TOOLCHAIN_VERSION := %s', cfg.ndktoolchainversion)
		end
		if cfg.ndkstl ~= nil then
			_p('  APP_STL := %s', cfg.ndkstl)
		end

		if cfg.optimize == p.OFF or cfg.optimize == "Debug" then
			_p('  APP_OPTIM := debug')
		elseif optim ~= nil then
			_p('  APP_OPTIM := release')
		end
	end
end
	
function premake.android.androidmk(sln)

	_p('LOCAL_PATH := $(call my-dir)')
	_p('')
		
	_p('ifndef config')
	_p(1, 'config=Release')
	_p('endif')
	_p('')
		
	for prj in premake.solution.eachproject(sln) do
		_p('include $(LOCAL_PATH)/%s.mk', prj.name)
	end
end
