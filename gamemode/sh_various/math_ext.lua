local Ints = {1000, 900, 500, 400, 100,90, 50, 40, 10, 9, 5, 4, 1}
local Nums = {"M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"}

function math.IntToRoman(int)
	if (int == 0) then return "N" end
	
	local Txt = ""
	
	if (int < 0) then Txt = "-" int = math.abs(int) end
	
	for i = 1, 13 do
		while (int >= Ints[i]) do
			int = int-Ints[i]
			Txt = Txt..Nums[i]
		end
	end
	
	return Txt
end

local NumberPrefix = {"k","m","b","t","q"}

function math.NiceInt(num)
	local Prefix = ""
	
	for k,v in pairs(NumberPrefix) do
		if (num >= 1000) then 
			Prefix = v
			num = math.ceil(num/10)/100
		else
			break
		end
	end
	
	return string.Comma(num).." "..Prefix,num,Prefix
end

function math.IsFloat(num)
	return (math.floor(num) != math.ceil(num))
end

function math.AngleNormalize(ang)
	return Angle(math.NormalizeAngle(ang.p),math.NormalizeAngle(ang.y),math.NormalizeAngle(ang.r))
end

function math.Distance2Points(x1,y1,x2,y2)
	return math.sqrt((x2-x1)^2+(y2-y1)^2)
end

function math.Distance2PointsSqr(x1,y1,x2,y2)
	return (x2-x1)^2+(y2-y1)^2
end

function math.Distance2Line(a,b,p)
    local nl = math.sqrt((b.x-a.x)*(b.x-a.x)+(b.y-a.y)*(b.y-a.y))
    return math.abs((p.x-a.x)*(b.y-a.y)-(p.y-a.y)*(b.x-a.x))/nl
end

function math.Distance2LineSqr(a,b,p)
    local nl = (b.x-a.x)*(b.x-a.x)+(b.y-a.y)*(b.y-a.y)
    return math.abs((p.x-a.x)*(b.y-a.y)-(p.y-a.y)*(b.x-a.x))/nl
end

function math.Increment2Points(x1,y1,x2,y2)
	return (y2-y1)/(x2-x1)
end

function math.LinearAngle(x1,y1,x2,y2)
	return math.atan2(y2-y1,x2-x1) * 180 / math.pi
end

function math.AngleDifferenceLines(v1,v2,v3)
	local A1 = math.LinearAngle(v1.x,v1.y,v2.x,v2.y)
	local A2 = math.LinearAngle(v1.x,v1.y,v3.x,v3.y)
	return math.abs(math.AngleDifference(A1,A2))
end

function math.Factorial(n)
	if (n == 0) then return 1 end
	for i = 2,n-1 do n = n*i end
	return n
end

function math.IsLeftOfLine(v1,v2,p)
	return ((v2.x - v1.x)*(p.y - v1.y) - (v2.y - v1.y)*(p.x - v1.x)) > 0
end

function math.SecondsToTime(secs)
	secs = math.floor(secs)
	
	local Txt	= ""
	
	for i = 0,2 do
		local It = 60^(2-i)
		local T = math.floor(secs/It)
		
		if (T<10) then Txt = Txt..":0"..T 
		else Txt = Txt..":"..T end
		
		secs = secs - T*It
	end
	
	return Txt:sub(2)
end

function math.EllipsoidEdge(Dir,Origin,Ang,Size)
	local Ab = Vector(0,0,0)
	Ab.x = Origin.x+Size.x*math.cos(math.rad(Dir.y))*math.sin(math.rad(-Dir.p+90))
	Ab.y = Origin.y+Size.y*math.sin(math.rad(Dir.y))*math.sin(math.rad(-Dir.p+90))
	Ab.z = Origin.z+Size.z*math.sin(math.rad(Dir.p+180))
	
	Ab:Rotate(Ang)
	
	return Ab
end

function math.Centerize(i,i_max,w)
    return -i_max * w / 2 + i * w
end
