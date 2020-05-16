

/* - More experiments on this required. Helped a lot in many RP servers, where there are too much crap around.

local co
local FadeDistance = 1000^2

local function checkRender()
	local allEnts
	local pl
	local sec1
	
	
	while (true) do
		pl = LocalPlayer()
		
		if (IsValid(pl)) then
			
			allEnts = ents.GetAll()
			
			if not next( allEnts ) then
				coroutine.yield()
			else
				for k, v in pairs( allEnts ) do
					pl = LocalPlayer()
					
					if (!IsValid(pl)) then
						break
					elseif (IsValid(v)) then
						if (v:GetPos():DistToSqr(pl:GetPos()) > FadeDistance) then
							if (v.DrawState == nil) then v.DrawState = v:GetNoDraw() end
							v:SetNoDraw(true)
						elseif (v.DrawState != nil) then
							v:SetNoDraw(v.DrawState)
							v.DrawState = nil
						end
					end
						
					if (k % 5 == 0) then coroutine.yield() end
				end
			end
		else
			coroutine.yield()
		end
	end
end

hook.Add( "Tick", "checkVisibleRender", function()
	if (!co or !coroutine.resume( co )) then
		co = coroutine.create( checkRender )
		coroutine.resume( co )
	end
end)
*/
