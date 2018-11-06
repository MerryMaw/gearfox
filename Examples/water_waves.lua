
local sin 	= math.sin
local cos 	= math.cos
local pi 	= math.pi

local CONSTANT_K = 2


function WaveZ(x,y,amp,wavelength,yaw,speed,Time)
	local dir 	= Angle(0,yaw,0):Forward()
	local w 	= 2*pi/wavelength
	local ts 	= Time * speed * w
	
	local z 	= amp*sin(dir:Dot(Vector(x,y,0))*w + ts)
	
	return z
end

local function f_H(pos,t,data)
	local w 	= (2*pi / data.length)
	local phase = data.speed * w
	
	local x = pos.x*1
	local y = pos.y*1
	local z = 0
	
	for i = 1,data.iter do
		local P = Vector(x,y,z)
		local W = w*data.dir:Dot(P) + phase*t
		
		x = x + data.steep * data.amp * data.dir.x * cos(W)
		y = y + data.steep * data.amp * data.dir.y * cos(W)
		
		//y = (data.steep * data.amp) * direction.y * Math.cos(wavenumber.y * (direction.dot(position)) + phase_const * time))
		
		z = z + data.amp * sin(W) 
	end
	
	return Vector(x,y,z)
end

function GerstnerWave(size,t,data)
	data		= data 			or {}
	data.amp 	= data.amp 		or 1
	data.length	= data.length 	or 5
	data.speed	= data.speed	or 0.5
	data.dir	= data.dir		or Vector(0,1,0)
	data.steep	= data.steep	or 0.5
	data.iter	= data.iter		or 5
	
	local data2 = table.Copy(data)
	data2.dir = Vector(1,0,0)
	
	
	local Set = {}
	
	for x = 1,size do
		Set[x] = {}
		for y = 1,size do
			Set[x][y] = f_H(Vector(x,y,0),t,data) + f_H(Vector(x,y,0),t,data2)
		end
	end
	
	return Set
end

function GerstnerWave_Pos(pos,t,data)
	return f_H(Vector(pos.x,pos.y,0),t,data)
end

function GerstnerWave_Ang(pos,t,data,zstretch)
	zstretch = zstretch or 1
	
	local B = f_H(Vector(pos.x,pos.y,0),t,data)
	local T = f_H(Vector(pos.y,pos.x,0),t,data)
	
	B.z = B.z * zstretch
	T.z = T.z * zstretch
	
	return B:Cross(T):Angle()
end









--DEBUG

if (SERVER) then return end

--local mat = Material( "editor/wireframe" ) 
local mat = Material("models/spawn_effect")

local size = 40
local stretch = 80
local stretchZ = 20
local origin = -Vector(size*stretch/2,size*stretch/2,0)
local scale	= 1000 


function GetDebugWaveData()
	return {
		amp 	= 0.7,
		length	= 9,
		speed	= 0.7,
		dir		= Angle(0,45,0):Forward(),
		steep	= 0.4,
		iter	= 5,
	}
end

local Dat = GetDebugWaveData()

function GetDebugWaveTime()
	return CurTime()
end

function GetDebugWavePos(pos)
	local wPos = GerstnerWave_Pos((-origin + pos) / stretch,GetDebugWaveTime(),Dat) + origin / stretch
	
	wPos.x = wPos.x * stretch
	wPos.y = wPos.y * stretch
	wPos.z = wPos.z * stretchZ
	
	return wPos
end

function GetDebugWaveAng(pos)
	return GerstnerWave_Ang((-origin + pos) / stretch,GetDebugWaveTime(),Dat,zstretch)
end




local function dFuncUV(v1,v2,v3,n,bTri)
	return {
		u1=v1.x / scale, v1=v1.y / scale,
		u2=v2.x / scale, v2=v2.y / scale,
		u3=v3.x / scale, v3=v3.y / scale,
		u4=v2.x / scale, v4=v2.y / scale,
	}
end 


hook.Add("PostDrawTranslucentRenderables", "TestGestner", function() 
	render.UpdateRefractTexture()
	render.SetMaterial( mat )
	
	local S = GerstnerWave(size,GetDebugWaveTime(),Dat) 
	local Tri = TerrainToTriangles_V2(S,stretch,stretchZ,origin,dFuncUV)

	mesh.Begin( MATERIAL_TRIANGLES, #Tri / 3 )
		for k,v in pairs(Tri) do
			mesh.Position( v.pos )
			mesh.TexCoord( 0, v.u, v.v)
			mesh.Color( 255, 255, 255, 255 )
			mesh.Normal( v.normal )
			mesh.AdvanceVertex()
		end
	mesh.End()
end)
		
	
