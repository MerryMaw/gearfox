-- original code by Ken Perlin: http://mrl.nyu.edu/~perlin/noise/
local lerp = Lerp

perlin = {}
perlin.p = {}
perlin.permutation = { 151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
  190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
  88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
  77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
  102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
  135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
  5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
  223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
  129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
  251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
  49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
  138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
}
perlin.size = 256
perlin.gx = {}
perlin.gy = {}
perlin.randMax = 256

for i=1,perlin.size do
	perlin.p[i] = perlin.permutation[i]
	perlin.p[256+i] = perlin.p[i] 
end

function perlin:noise( x, y, z )
    local X = bit.band(math.floor(x), 255) + 1
    local Y = bit.band(math.floor(y), 255) + 1
    local Z = bit.band(math.floor(z), 255) + 1

    x = x - math.floor(x)
    y = y - math.floor(y)
    z = z - math.floor(z)
	
    local u = fade(x)
    local v = fade(y)
    local w = fade(z)
    local A  = self.p[X]+Y
    local AA = self.p[A]+Z
    local AB = self.p[A+1]+Z
    local B  = self.p[X+1]+Y
    local BA = self.p[B]+Z
	
    local BB = self.p[B+1]+Z

    return lerp(w, lerp(v, lerp(u, grad(self.p[AA  ], x  , y  , z  ),
                                   grad(self.p[BA  ], x-1, y  , z  )),
                           lerp(u, grad(self.p[AB  ], x  , y-1, z  ),
                                   grad(self.p[BB  ], x-1, y-1, z  ))),
                   lerp(v, lerp(u, grad(self.p[AA+1], x  , y  , z-1),
                                   grad(self.p[BA+1], x-1, y  , z-1)),
                           lerp(u, grad(self.p[AB+1], x  , y-1, z-1),
                                   grad(self.p[BB+1], x-1, y-1, z-1))))
end


function fade( t )
    return t * t * t * (t * (t * 6 - 15) + 10)
end
 
perlin.dot_product = {
    [0x0]=function(x,y,z) return  x + y end,
    [0x1]=function(x,y,z) return -x + y end,
    [0x2]=function(x,y,z) return  x - y end,
    [0x3]=function(x,y,z) return -x - y end,
    [0x4]=function(x,y,z) return  x + z end,
    [0x5]=function(x,y,z) return -x + z end,
    [0x6]=function(x,y,z) return  x - z end,
    [0x7]=function(x,y,z) return -x - z end,
    [0x8]=function(x,y,z) return  y + z end,
    [0x9]=function(x,y,z) return -y + z end,
    [0xA]=function(x,y,z) return  y - z end,
    [0xB]=function(x,y,z) return -y - z end,
    [0xC]=function(x,y,z) return  y + x end,
    [0xD]=function(x,y,z) return -y + z end,
    [0xE]=function(x,y,z) return  y - x end,
    [0xF]=function(x,y,z) return -y - z end
}
function grad(hash, x, y, z)
    return perlin.dot_product[bit.band(hash,0xF)](x,y,z)
end
/*
//Debug
if (SERVER) then return end

local max = math.max
local sqrt = math.sqrt
local abs = math.abs
local sin = math.sin
local cos = math.cos
local log = math.log

local TW = 64
local TH = TW

local setdrawcolor 	= surface.SetDrawColor
local drawrect 		= surface.DrawRect

local scrX,scrY = 50,50
local BE = {}
local T = 0
local TY = 0

local Spacing = 0


//Test planet size

local XMax = 20 
local YMax = 10

hook.Add("HUDPaint","TestPerlinNoise",function()
	T = math.random(0,XMax)
	TY = math.random(0,YMax)
	
	BE[T] = BE[T] or {}
	BE[T][TY] = CreateTexture("PerlinNoise"..T.."_"..TY,TW,TH,function(w,h)
		local OffsetW = T*TW
		local OffsetH = TY*TH
	 
		for x = 0,w do
			local X = (OffsetW + x)/w
			
			for y = 0,h do
				local Y = (OffsetH + y)/h
				
				local Lat = sin(math.rad(180 * Y/(YMax+1)))
				local Long = (cos(math.rad(90 * X/(XMax+1)))*Lat)
				
				local val = perlin:noise(Long*X,Lat*Y,5)*math.pi
				
				local g = 0.6 + 0.4 * cos(val)
				local b = 0.7 + 0.3 * sin(val)
				local r = g * b
				
				setdrawcolor( 
					255 * r,
					255 * g,
					255 * b,
					255
				)
				
				drawrect(x,y,1,1)
			end
		end
	end)
	
	surface.SetDrawColor(0,0,0,20)
	surface.DrawRect(scrX,scrY,TW,20)
	
	for x,v in pairs(BE) do
		for y,mat in pairs(v) do
			surface.SetMaterial(mat)
			surface.DrawTexturedRect(scrX+(TW+Spacing)*x,scrY+(TH+Spacing)*y,TW,TH)
		end
	end
end)*/