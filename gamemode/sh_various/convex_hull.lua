
-- My implementation of Gift-wrapping for Convex Hulls given set of points
local leftline = math.IsLeftOfLine 

-- This returns a convex hull on a 2d plane, ignoring the z value of points.
function Jarvis_Hull2D(dat)
	if (#dat <= 3) then return dat end
	if (!leftline) then leftline = math.IsLeftOfLine  end
	
	local p 			= {}
	local pID			= {}
	local StartVec 		= dat[1]
	local StartVecID 	= 1
	local ndat 			= #dat
	
	//Find left most point
	for i = 1,ndat do
		if (dat[i].x < StartVec.x) then 
			StartVec = dat[i] 
			StartVecID = i
		end
	end
	
	//Start the chain!!
	local i = 1
	local ep
	
	repeat
		p[i] 	= StartVec
		pID[i] 	= StartVecID
		
		ep 			= dat[1]
		StartVecID 	= 1
		
		for j = 1,ndat do
			if (ep == StartVec or leftline(p[i],ep,dat[j])) then
				ep 			= dat[j]
				StartVecID 	= j
			end
		end
		
		
		i = i+1
		StartVec = ep
	until (ep == p[1])
	
	p[i] = ep
		
	return p,pID
end





// concave hull (NOTE: RETURNS EDGES NOT VERTEX TABLE)

local min 		= math.min
local max 		= math.max
local abs 		= math.abs

local remove 	= table.remove
local insert 	= table.insert

local function createEdge(p1,p2)
	return {edge = {p1,p2},dis = (p2-p1):Length2D()}
end

local function onSeg(p,q,r)
	if (q.x <= max(p.x, r.x) and q.x >= min(p.x, r.x) and
        q.y <= max(p.y, r.y) and q.y >= min(p.y, r.y)) then
		return true
	end
 
    return false
end

local function orientation(p,q,r)
	local o = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
	
    if (o == 0) then 	return 0
	elseif (o > 0) then return 1
	else 				return 2 
	end
end

local function intersectEdge(e1,e2)
	local p1 = e1.edge[1]
	local p2 = e1.edge[2]
	local p3 = e2.edge[1]
	local p4 = e2.edge[2]
	
	if (p1 == p3 or p1 == p4 or p2 == p3 or p2 == p4) then return false end
	
	local o1 = orientation(p1,p2,p3)
	local o2 = orientation(p1,p2,p4)
	local o3 = orientation(p3,p4,p1)
	local o4 = orientation(p3,p4,p2)
	
	if (o1 != o2 and o3 != o4) then return true end
	
    if (o1 == 0 and onSeg(p1, p3, p3)) then return true end
    if (o2 == 0 and onSeg(p1, p4, p2)) then return true end
    if (o3 == 0 and onSeg(p3, p1, p4)) then return true end
    if (o4 == 0 and onSeg(p3, p2, p4)) then return true end
 
    return false
end

function GenerateConcaveHull2D(dat,dis)	
	if (!dis2points) then dis2points = math.Distance2Points end
	
	local vex,vexID = Jarvis_Hull2D(dat)
	local ndat 		= #dat
	local res 		= {}
	local resID		= {}
	
	local edges 	= {}
	local nvex		= #vex
	
	for i = 1,nvex-1 do
		edges[i] = createEdge(vex[i],vex[i+1])
		resID[vexID[i]] = true
	end
	
	table.sort(edges,function(a,b) return a.dis < b.dis end)
	
	local i 	= 1
	local ec	= #edges
	
	while (ec > 0) do
		//Select first edge in line and remove it from edges
		ec = ec-1
		local p 	= remove(edges,1)
		local ic 	= false
		
		if (p.dis > dis) then
			local pos 	= p.edge[1]
			local ep 	= p.edge[2] 
			
			//Find closest point to edge
			local la 	= nil
			local a		= {45,45}
			local d 	= p.dis
			
			for j = 1,ndat do
				if (!resID[j]) then
					local p2 = dat[j]
					--local a1  = math.LinearAngle(pos.x,pos.y,p2.x,p2.y) --dis2points(pos.x,pos.y,p2.x,p2.y)
					--local a2  = math.LinearAngle(ep.x,ep.y,p2.x,p2.y) --dis2points(ep.x,ep.y,p2.x,p2.y)
					local a1  	= math.AngleDifferenceLines(pos,ep,p2)
					local a2  	= math.AngleDifferenceLines(ep,p2,pos)
					local d2 	= math.Distance2Line(pos,ep,p2)
					
					if (a1 < a[1] and a2 < a[2]and a1 > 0 and a2 > 0) then
						la 		= {p2,j}
						a 		= {a1,a2}
					end 
				end
			end
			
			//Success? Check edge intersections
			if (la) then
				local e1 = createEdge(pos,la[1])
				local e2 = createEdge(la[1],ep)
				
				if (i > 0) then
					for k = 1,i-1 do
						if (intersectEdge(res[k],e1) or intersectEdge(res[k],e2)) then ic = true break end
					end
					
					if (!ic) then
						for k = 1,ec do
							if (intersectEdge(edges[k],e1) or intersectEdge(edges[k],e2)) then ic = true break end
						end 
					end
				end
				
				if (!ic) then
					edges[ec+1] = e1
					edges[ec+2] = e2
					ec 	= ec+2
					resID[la[2]] = true
				end
			else
				ic = true
			end
		else
			ic = true
		end
		
		if (ic) then
			res[i] = p
			i = i+1
		end
	end
	
	res = OrderConcaveHull2D(res)	
	
	return res,vex
end

--Cleaning up the order of edges ;P probably could do table.sort but meh
function OrderConcaveHull2D(edges)
	local temp = edges[1]
	local i = 1
	local nedg = #edges
	
	while (i < nedg) do
		for k = 1,nedg do
			if (edges[i].edge[2]:IsEqualTol(edges[k].edge[1],0)) then
				temp = edges[i+1]
				edges[i+1] = edges[k]
				edges[k] = temp
				break
			end
		end
		
		i = i+1
	end
	
	return edges
end
		




