-- Function to make sure that an option in a given config is the same for every project
-- Additionnaly, replace "default" with "nil"
local function agregateOption(sln, cfg, option)
  local first = true
  local val
  for prj in premake.solution.eachproject(sln) do
    for prjcfg in premake.eachconfig(prj) do
      if prjcfg.shortname == cfg.shortname then
        if first then
          first = false
          val = prjcfg[option]
        else
          if prjcfg[option] ~= val then
            error("Value for "..option.." must be the same on every project for configuration "..cfg.longname.." in solution "..sln.name)
          end
        end
      end
    end
  end
  if val == "default" then
    return nil
  end
  return val
end



function premake.android.applicationmk(sln)
    local sln = premake.solution.get(1)
	if sln ~= nil then
		if sln.ndkabi ~= nil then
			_p('  APP_ABI := %s', sln.ndkabi)
		end
		if sln.ndkplatform ~= nil then
			_p('  APP_PLATFORM := %s', sln.ndkplatform)
		end
		if sln.ndktoolchainversion ~= nil then
			_p('  NDK_TOOLCHAIN_VERSION := %s', sln.ndktoolchainversion)
		end
		if sln.ndkstl ~= nil then
			_p('  APP_STL := %s', sln.ndkstl)
		end

		if sln.optimize == p.OFF or sln.optimize == "Debug" then
			_p('  APP_OPTIM := debug')
		elseif sln.optim ~= nil then
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
