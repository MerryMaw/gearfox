
--Took a while to get the right algorithm for this..
--By The Maw

local insert 	= table.insert
local Clamp	 	= math.Clamp

local FactorialTableData = {}

/*
	Minor functions calculating the binomial coefficients for BCurves
*/

local function m_Factor_t(i) 
	if (FactorialTableData[i]) then return FactorialTableData[i] end
	FactorialTableData[i] = math.Factorial(i)
	return FactorialTableData[i]
end
	
local function binomial_coefficient(n,i)
	return (m_Factor_t(n) / (m_Factor_t(i) * m_Factor_t(n-i)))
end

/*
	BezierCurve_Point
*/

function BezierCurve_Point(tVector,t,tmax)
	tmax 	= tmax or 1
	t 		= t/tmax
	
	local t_inv = Clamp(1-t,0,1)
	
	local Sum = Vector(0,0,0)
	local n   = #tVector-1
	
	for i,P in pairs(tVector) do
		i = i-1
		Sum = Sum+binomial_coefficient(n,i)*t_inv^(n-i)*t^i*P
	end
	
	return Sum
end

BezierCurve_Point_N = BezierCurve_Point

/*
	BezierCurve_Point_Build
*/

function BezierCurve_Point_Build(tVector,Steps)
	local r	= {}
	for t = 1,Steps do r[t] = BezierCurve_Point(tVector,t-1,Steps-1) end
	return r
end

/*
	BezierCurve_Casteljau
*/

local function evaluateIntersect(t,curve)
	local Data = {}
	local n = #curve
	
	Data[0] = {}
	
	for i = 1,n do Data[0][i-1] = curve[i] end
	
	for x = 1,n do
		Data[x] = {}
		
		for y = 0,(n-x)-1 do
			Data[x][y] = LerpVector(t,Data[x-1][y],Data[x-1][y+1])
		end
	end
	
	return Data[n-1][0]
end

function BezierCurve_Casteljau(t,c1,c2)
	local x = evaluateIntersect(t,c1)
	local y = evaluateIntersect(t,c2)
	return {x,y}
end
			



if (CLIENT) then
	local tan	 = math.tan
	local rad	 = math.rad

	local MPos = mesh.Position
	local MNor = mesh.Normal
	local MAdv = mesh.AdvanceVertex
	
	function CurveToMesh(Curve,Size,iter)
		local Step = 360/iter
		
		local BSiz 		= tan(rad(Step/4))*Size
		local BHeight 	= BSiz/iter*4
		
		local LastAng = nil
		
		mesh.Begin(MATERIAL_QUADS,(#Curve-1)*iter)
			for k,v in pairs(Curve) do
				local NextCurve = Curve[k+1]
				
				if (NextCurve) then
					local Ang 	= (NextCurve-v):Angle()
					local Ang2 	= LastAng or Ang*1
					
					for i = 1,iter do
						local Rig 	= Ang:Right()
						local Rig2 	= Ang2:Right()
						
						MPos( v+Rig2*BSiz )
						MNor( Rig2 )
						MAdv()
			 
						MPos( NextCurve+Rig*BSiz )
						MNor( Rig )
						MAdv()
						
						Ang:RotateAroundAxis(Ang:Forward(),Step)
						Ang2:RotateAroundAxis(Ang2:Forward(),Step)
						
						local Rig 	= Ang:Right()
						local Rig2 	= Ang2:Right()
			 
						MPos( NextCurve+Rig*BSiz )
						MNor( Rig )
						MAdv()
						
						MPos( v+Rig2*BSiz )
						MNor( Rig2 )
						MAdv()
					end
					
					LastAng = Ang
				end
			end
		mesh.End()
	end
end
			