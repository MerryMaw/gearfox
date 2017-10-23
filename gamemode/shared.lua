include("autolua.lua")

AddLuaCSFolder("cl_various")
AddLuaCSFolder("cl_hud/vgui")
AddLuaCSFolder("cl_hud/menus")
AddLuaCSFolder("cl_hud")

AddLuaSHFolder("sh_various")

AddLuaSVFolder("sv_various")

GM.Name 			= "Gearfox"
GM.Author 			= "The Maw"
GM.Email 			= "cjbremer@gmail.com"
GM.Website 			= "www.devinity2.com"
GM.Version			= 1.4


function GM:PlayerNoClip( pl )
	return pl:IsAdmin()
end