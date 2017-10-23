--Snippit for moving sprite textures.. Warning: GLua is slow so using this instead of source engines detail is a stupid idea! Only for small exact things!
--Experiment by The Maw
/*

local Dir  = Vector(16,0,0)
local DirH = Vector(0,0,16)
--local Ang  = Angle(0,120,0)

local mat = Material("starwarsrp/grass.png","nocull vertexlitgeneric alphatest smooth mips")

local function AddQuad(pos,Ang,x,y,w,h)
	local r = Ang:Right()
	local u = Ang:Up()
	local f = Ang:Forward()
	local startpos = pos+u*y+r*x
	return {
		--Tri1
		{
			pos		= startpos,
			normal	= f,
			u		= 1,
			v		= 1,
		},
		{
			pos		= startpos+u*h,
			normal	= f,
			u		= 1,
			v		= 0,
		},
		{
			pos		= startpos+u*h+r*w,
			normal	= f,
			u		= 0,
			v		= 0,
		},
		--Tri2
		{
			pos		= startpos,
			normal	= f,
			u		= 1,
			v		= 1,
		},
		{
			pos		= startpos+u*h+r*w,
			normal	= f,
			u		= 0,
			v		= 0,
		},
		{
			pos		= startpos+r*w,
			normal	= f,
			u		= 0,
			v		= 1,
		},
	}
end
		
local up 		= Vector(0,0,0)
local roughness = 30
local m
function PlantSpriteAtVector(Origin,BoxSize,MaxSprites,UVTable)
	local V 	= {}
	
	up.z = BoxSize.z
	
	for i = 1,MaxSprites,roughness do
		local Random = Vector(math.Rand(-1,1),math.Rand(-1,1),0) * BoxSize
		
		for k = 1,roughness do
			local Random2 = Vector(math.Rand(-1,1),math.Rand(-1,1),0) * 60
			local Tr = util.TraceLine({
				start = Origin+Random+up+Random2,
				endpos = Origin+Random-up+Random2,
				mask = MASK_SOLID_BRUSHONLY,
			})
			
			if (Tr.Hit and Tr.HitWorld) then 
				local Ang = Angle(0,math.random(0,360),0)
				table.Add(V,AddQuad(Tr.HitPos,Ang,-40,0,80,60+30*math.cos(Tr.HitPos.x+Tr.HitPos.y)))
			end
		end
		
	end
	
	if (m) then m:Destroy() end
	
	m = Mesh()
	m:BuildFromTriangles(V)
	
	
	return m
end


//TEST
hook.Add("PostDrawTranslucentRenderables","RenderPlants",function()
	if (m) then
		render.SetMaterial(mat)
		m:Draw()
	end
end)
*/
/*
	lua_run_cl PlantSpriteAtVector(player.GetByID(1):GetPos(),Vector(100,100,100),{"gearfox/grass.png",},300)
*/