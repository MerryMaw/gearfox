-- :) The diamond square algorithm. Used for terrain generation and image stuff.
-- Function CreateTerrain(Size (2 powered by Size), maximum height, Smoothness, Seed (Optional else 1) )
-- Returns a 2d table with a height defined on it

local random 	= math.random
local ceil 		= math.ceil
local rad		= math.rad
local sin		= math.sin
local cos		= math.cos
local max		= math.max

local add	= table.Add
local vec   = Vector

//Standard Diamond-Square implementation. 
function CreateEmptyTerrain(size,grid)
	local S 	= 2^size
	
	local Grid = grid or {}
	
	for X=0,S do 
		Grid[X] = Grid[X] or {}
		for Y=0,S do 
			Grid[X][Y] = Grid[X][Y] or 0
		end
	end
	
	return Grid
end
	
function CreateTerrain(size,maxheight,smoothness,seed,bseamless_hor,Grid)
	math.randomseed(seed or 1)
	
	local S 	= 2^size
	local SS 	= S*1

	local Grid = CreateEmptyTerrain(size,Grid)
	
	//Iterations
	local Iteration = 0
	
	while (S>1) do
		Iteration = Iteration+1
		
		local SF = ceil(SS/S)
		
		for X=0,SF-1 do
			local XX = S*X
			
			for Y=0,SF-1 do
				local YY = S*Y
				
				if (bseamless_hor) then
					if (XX == 0) then
						Grid[0][YY+S/2] = Grid[SS][YY+S/2] 
						Grid[0][YY] = Grid[SS][YY] 
						Grid[0][YY+S] = Grid[SS][YY+S] 
					end 
				end
				
				Grid[XX+S/2][YY+S/2] 	= (Grid[XX][YY]+Grid[XX+S][YY]+Grid[XX+S][YY+S]+Grid[XX][YY+S])/4+random(-maxheight,maxheight)
				
				Grid[XX+S/2][YY] 		= (Grid[XX][YY]+Grid[XX+S][YY])/2+random(-maxheight,maxheight)
				Grid[XX+S/2][YY+S] 		= (Grid[XX+S][YY+S]+Grid[XX][YY+S])/2+random(-maxheight,maxheight)
				
				Grid[XX][YY+S/2] 		= (Grid[XX][YY]+Grid[XX][YY+S])/2+random(-maxheight,maxheight)
				Grid[XX+S][YY+S/2] 		= (Grid[XX+S][YY]+Grid[XX+S][YY+S])/2+random(-maxheight,maxheight)
			end	
		end
		
		maxheight = maxheight/smoothness
		S = S/2
	end
	
	return Grid
end


//A very experimental algorithm. Not finished yet
function CreateTerrainSpherical(size,maxheight,smoothness,seed)
	local Grid 		= CreateTerrain(size,maxheight,smoothness,seed,true)
	
	local S 	= 2^size-1
	local Sc	= 2^size/2
	local pi 	= math.pi
	
	local NewGrid 	= {}
	 
	for x=0,S do
		local nx = (x-Sc)/Sc
		local lo = nx * pi
		NewGrid[x] = {}
		
		for y=0,S do
			local ny = (y-Sc)/Sc
			local la = math.atan(math.exp(-2*pi*ny))
			//lo/la to Hammer-Aitoff coordinates
			local sz = math.sqrt(1+cos(la)*cos(lo/2))
			local sx = Sc+ceil(Sc*cos(la) * sin(lo/2) / sz)
			local sy = ceil(S*sin(la) / sz)
			
			//Hammer-Aitoff to lo/la
			NewGrid[x][y] = Grid[sx][sy]
		end
	end
	
	return NewGrid,Grid
end


function TerrainToTriangles(Terrain,StretchX,StretchY,TextureScaleX,TextureScaleY,Origin)
	local Triangles = {}
	
	for x,a in pairs(Terrain) do
		local Tab = Terrain[x+1]
		if (Tab) then
			for y,z in pairs(a) do
				if (a[y+1]) then
					local V1 = vec(x*StretchX,y*StretchY,z)
					local V2 = vec((x+1)*StretchX,y*StretchY,Tab[y])
					local V3 = vec((x+1)*StretchX,(y+1)*StretchY,Tab[y+1])
					local V4 = vec(x*StretchX,(y+1)*StretchY,a[y+1])
					
					local N1 = (V3-V2):Cross(V1-V2)
					local N2 = (V1-V4):Cross(V3-V4)
					
					add(Triangles,{
						--Triangle 1
						{
							pos = Origin+V3,
							normal = N1,
						},
						{
							pos = Origin+V2,
							normal = N1,
						},
						{
							pos = Origin+V1,
							normal = N1,
						},
						--Triangle 2
						{
							pos = Origin+V1,
							normal = N2,
						},
						{
							pos = Origin+V4,
							normal = N2,
						},
						{
							pos = Origin+V3,
							normal = N2,
						},
					})
				else
					break
				end
			end
		else
			break
		end
	end
	
	return Triangles
end
	
	