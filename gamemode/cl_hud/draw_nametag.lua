
local UpVec = Vector(0,0,80)
local C	 	= MAIN_TEXTCOLOR
local EnaTa = true

function GM:SetEnableMawNameTag(bool)
	EnaTa = bool
end

hook.Add("HUDPaint","DrawingNames",function()
	if (!EnaTa) then return end
	
	local lp = LocalPlayer()
	
	for k,pl in pairs( player.GetAll() ) do
		if (lp != pl) then 
			local Dis = pl:GetPos():Distance(lp:GetPos())
			
			if (Dis < 800) then
				local spos	= (pl:GetPos()+UpVec):ToScreen()
				local Alpha = math.Clamp(Dis/800,0,1)
				local A		= C.a*1
				
				C.a = A-A*Alpha
				
				DrawText( pl:Nick(), "MBPlayerNameFont", spos.x, spos.y, C, 1 )
				
				C.a = A
			end
		end
	end
end)