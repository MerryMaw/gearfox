
local insert = table.insert
local add	 = table.Add
local asin 	 = math.asin

local t	= (1 + math.sqrt(5.0)) / 2.0
local Vs = {}
Vs[0]  =	Vector(-1,t,0)
Vs[1]  =	Vector(1,t,0)
Vs[2]  =	Vector(-1,-t,0)
Vs[3]  =	Vector(1,-t,0)
	
Vs[4]  =	Vector(0,-1,t)
Vs[5]  =	Vector(0,1,t)
Vs[6]  =	Vector(0,-1,-t)
Vs[7]  =	Vector(0,1,-t)
	
Vs[8]  =	Vector(t,0,-1)
Vs[9]  =	Vector(t,0,1)
Vs[10] =	Vector(-t,0,-1)
Vs[11] =	Vector(-t,0,1)
	
local function AddFace(a,b,c)
	return {
		{
			pos = Vs[c],
		},
		{
			pos = Vs[b],
		},
		{
			pos = Vs[a],
		},
	}
end

local function GetMiddle(A,B)
	return (A+B)/2
end
	
	

function Geosphere(iter,func) 
	func = func or function(pos,iter) return pos end
	
	--Add base triangles
	local Faces = {
		AddFace(0,11,5),
		AddFace(0,5,1),
		AddFace(0,1,7),
		AddFace(0,7,10),
		AddFace(0,10,11),
	
		AddFace(1,5,9),
		AddFace(5,11,4),
		AddFace(11,10,2),
		AddFace(10,7,6),
		AddFace(7,1,8),
		
		AddFace(3,9,4),
		AddFace(3,4,2),
		AddFace(3,2,6),
		AddFace(3,6,8),
		AddFace(3,8,9),
	
		AddFace(4,9,5),
		AddFace(2,4,11),
		AddFace(6,2,10),
		AddFace(8,6,7),
		AddFace(9,8,1),
	}
	
	--refine
	for i=0,iter-1 do
		local newFaces = {}
		local i2 = 1
		for k,tri in pairs(Faces) do
			tri[1].pos = func(tri[1].pos,i)
			tri[2].pos = func(tri[2].pos,i)
			tri[3].pos = func(tri[3].pos,i)
			
			local a = GetMiddle(tri[1].pos,tri[2].pos)
			local b = GetMiddle(tri[2].pos,tri[3].pos)
			local c = GetMiddle(tri[3].pos,tri[1].pos)
			
			newFaces[i2] = {
				tri[1],
				{pos = a,},
				{pos = c,}}
			
			newFaces[i2+1] = {
				tri[2],
				{pos = b,},
				{pos = a,}}
			
			newFaces[i2+2] = {
				tri[3],
				{pos = c,},
				{pos = b,}}
			
			newFaces[i2+3] = {
				{pos = a,},
				{pos = b,},
				{pos = c,}}
			
			i2 = i2+4
		end
		
		Faces = newFaces
	end
	
	local Tri = {}
	
	--Flattens
	local ia = 0
	local pi = math.pi + 0.5
	for k,v in pairs(Faces) do
		for i,vert in pairs(v) do
			ia=ia+1
			
			local N = v[i].pos:GetNormalized()
			
			local U = asin(N.x) / pi
            local V = asin(N.z) / pi
			
			Tri[ia] = {
				pos = v[i].pos,
				normal = N,
				u = U,
				v = V,
			}
		end
	end
	
	return Tri
end