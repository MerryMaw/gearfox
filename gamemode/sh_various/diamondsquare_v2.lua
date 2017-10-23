-- A V2 of my implementation of Diamond Square.
local random 	= math.random
local max		= math.max

local add	= table.Add
local vec   = Vector

//Standard Diamond-Square implementation. 
local function createEmptyTab(n)
	local t = {}
	for i=0,n do t[i] = 0 end
	return t
end

local function squareStep(grid,x,y,r,func)
	local s,num = 0,0
	
	if (x-r >= 0) then
		if (0 <= y-r) 		then s,num = s + grid[x-r][y-r], num+1 end
		if (grid.h >= y+r) 	then s,num = s + grid[x-r][y+r], num+1 end
	end
	
	if (grid.w >= x+r) then
		if (0 <= y-r) 		then s,num = s + grid[x+r][y-r], num+1 end
		if (grid.h >= y+r) 	then s,num = s + grid[x+r][y+r], num+1 end
	end
	
	grid[x][y] = func(grid,x,y,r,s/num)
end
 
local function diamondStep(grid,x,y,r,func)
	local s, num = 0,0
	
    if (0 <= x-r)  	 	then s, num = s + grid[x-r][y], num + 1 end
    if (x+r <= grid.w) 	then s, num = s + grid[x+r][y], num + 1 end
    if (0 <= y-r)		then s, num = s + grid[x][y-r], num + 1 end
    if (y+r <= grid.h) 	then s, num = s + grid[x][y+r], num + 1 end
	
    grid[x][y] = func(grid,x,y,r,s/num)
end

local function diamondSquare(n,func)
	local grid = {w=n,h=n}
	for x = 0, n do grid[x] = createEmptyTab(n) end
	
	local r = n
	
	grid[0][0] = func(grid,0,0,r,0)
	grid[0][r] = func(grid,0,r,r,0)
	grid[r][0] = func(grid,r,0,r,0)
	grid[r][r] = func(grid,r,r,r,0)
	
	r = r/2
	
	while (1 <= r) do
		for x = r, grid.w-1, 2*r do
			for y = r, grid.h-1, 2*r do
				squareStep(grid,x,y,r,func)
			end
			for y = 0, grid.h, 2*r do
				diamondStep(grid,x,y,r,func)
			end
		end
		for x = 0, grid.w, 2*r do
			for y = r, grid.h-1, 2*r do
				diamondStep(grid,x,y,r,func)
			end
		end
		
		r = r/2
	end
	return grid
end

local function dFunc(grid, x, y, r, h)
    return h + (random()-0.5)*r
end
	

function CreateTerrain_V2(n,func)
	func = func or dFunc
	
	return diamondSquare(2^n,func)
end

local function dFuncUV(v1,v2,v3,n,tri)
	return {
		u1=0,v1=0,
		u2=1,v2=0,
		u3=1,v3=1,
		u4=0,v4=1,
	}
end

function TerrainToTriangles_V2(Terrain,StretchX,StretchY,Origin,funcUV,smoothness)
	funcUV = funcUV or dFuncUV
	local Triangles = {}
	
	local PrevN1,PrevN2 = Vector(0,0,1),Vector(0,0,1)
	smoothness = smoothness or 0.45
	
	for x,a in pairs(Terrain) do
		local Tab = Terrain[x+1]
		if (Tab) then
			for y,z in pairs(a) do
				if (a[y+1]) then
					local V1 = vec(x*StretchX,y*StretchY,z)
					local V2 = vec((x+1)*StretchX,y*StretchY,Tab[y])
					local V3 = vec((x+1)*StretchX,(y+1)*StretchY,Tab[y+1])
					local V4 = vec(x*StretchX,(y+1)*StretchY,a[y+1])
					
					if (type(z) == "Vector") then
						V1 = z * StretchX
						V2 = Tab[y] * StretchX
						V3 = Tab[y+1] * StretchX
						V4 = a[y+1] * StretchX
						
						V1.z = z.z * StretchY
						V2.z = Tab[y].z * StretchY
						V3.z = Tab[y+1].z * StretchY
						V4.z = a[y+1].z * StretchY
					end
					
					local N1 = (V3-V2):Cross(V1-V2)
					local N2 = (V1-V4):Cross(V3-V4)
					
					local uv 	= funcUV(V1,V2,V3,N1,false)
					local uv2 	= funcUV(V1,V4,V3,N2,true)  
					
					local n1 = LerpVector(smoothness*2,LerpVector(smoothness,N1,N2),PrevN1)
					local n2 = LerpVector(smoothness*2,LerpVector(smoothness,N2,N1),PrevN2)
					
					PrevN1 = n1
					PrevN2 = n2
					
					add(Triangles,{
						--Triangle 1
						{
							pos = Origin+V3,
							normal = n1,
							u = uv.u3,
							v = uv.v3,
							color = uv.c3,
						},
						{
							pos = Origin+V2,
							normal = n1,
							u = uv.u2,
							v = uv.v2,
							color = uv.c2,
						},
						{
							pos = Origin+V1,
							normal = n1,
							u = uv.u1,
							v = uv.v1,
							color = uv.c1,
						},
						--Triangle 2
						{
							pos = Origin+V1,
							normal = n2,
							u = uv2.u1,
							v = uv2.v1,
							color = uv2.c1,
						},
						{
							pos = Origin+V4,
							normal = n2,
							u = uv2.u4,
							v = uv2.v4,
							color = uv2.c4,
						},
						{
							pos = Origin+V3,
							normal = n2,
							u = uv2.u3,
							v = uv2.v3,
							color = uv2.c3,
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
