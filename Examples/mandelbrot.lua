-- CLIENTSIDE

local max = math.max
local sqrt = math.sqrt
local abs = math.abs
local sin = math.sin
local cos = math.cos
local log = math.log

local b = {}
local zMax = 950
local W = 1024
local H = W

local setdrawcolor 	= surface.SetDrawColor
local drawrect 		= surface.DrawRect

local t = 0

local X,Y = ScrW()/2-W/2,ScrH()/2-H/2

hook.Add("HUDPaint","TestMandelbrot",function()
	t = 500 --UnPredictedCurTime()*20
	local i = math.floor(t)%zMax
	
	local zoomfactor = 10^(i/70)
	local iMax = math.ceil(sqrt(abs(2*sqrt(abs(2-sqrt(5*zoomfactor)))))*66.5)
	
	b[i] = CreateTexture("Fractal"..i,W,H,function(w,h)
		for x,v in pairs(GenerateMandelBrot(2/zoomfactor,iMax,max(W,H),0.267235642726, -0.003347589624)) do
			for y,zn in pairs(v) do
				local z,n 		= zn.z,zn.n
				local nsmooth 	= n + 1 - (log(log(abs(z)))/log(2))
				
				if (z == 0) then continue end
				
				local r = 0.6 + 0.4 * cos(nsmooth/6)
				local b = 0.7 + 0.3 * sin(nsmooth/6)
				local g = r * b
				
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
	surface.DrawRect(X,Y,W,20)
	
	surface.SetMaterial(b[i])
	surface.DrawTexturedRect(X,Y,W,H)
	
	draw.SimpleText("Zoom: ("..i..") 10^"..math.Truncate(i/70,3),"BudgetLabel",X,Y,Color(255,255,0))
	draw.SimpleText("Iterations: "..iMax,"BudgetLabel",X,Y+10,Color(255,255,0))
end)