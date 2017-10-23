
include( "shared.lua" )

GM.UseMawChat 		= true
GM.UseMawBlockCHud 	= true

--hook.Remove( "PostDrawEffects", "RenderHalos" )

function GM:Initialize()
end

function GM:ShouldDrawLocalPlayer()
	return (!IsFirstPerson())
end

function GM:CallScreenClickHook()
end



