
/*
	Noded version of A-Star.
	- The Maw
*/


local insert = table.insert
local remove = table.remove
local abs	 = math.abs


function AS_AddNode(nodeMap,vec,radius)
	local Node = {
		pos 		= vec,
		range		= radius,
		edges_num 	= 0,
		edges 		= {}
	}
	
	for nodeid,node in pairs(nodeMap) do
		if (vec:Distance(node.pos) > radius) then continue end
		local tr 	= util.TraceLine({
			start 	= vec,
			endpos 	= node.pos,
			mask 	= MASK_SOLID_BRUSHONLY
		})
		
		if (!tr.Hit) then
			Node.edges_num 				= Node.edges_num + 1
			Node.edges[Node.edges_num] 	= node
			
			node.edges_num 				= node.edges_num + 1
			node.edges[node.edges_num] 	= Node
		end
	end
	
	insert(nodeMap,Node)
end

--Slightly expensive, but will relink all the nodes incase of corruption. 
--Should'nt be necessary, but I am leaving it here. 
function AS_RelinkNodes(nodeMap)
	for sn_id,sn in pairs(nodeMap) do
		sn.edges = {}
		sn.edges_num = 0
		
		for en_id,en in pairs(nodeMap) do
			local tr 	= util.TraceLine({
				start 	= sn.pos,
				endpos 	= en.pos,
				mask 	= MASK_SOLID_BRUSHONLY
			})
			
			if (!tr.Hit) then
				sn.edges_num 			= sn.edges_num+1
				sn.edges[sn.edges_num] 	= en
			end
		end
	end
end
			

function AS_RemoveNode(nodeMap,vec)
	for nodeid,node in pairs(nodeMap) do
		if (node.pos == vec) then
			remove(nodeMap,nodeid)
		else
			--Remove any associations with this node
			for edgeid,edge in pairs(node.edges) do
				if (edge.pos == vec) then
					node.edges_num = node.edges_num - 1
					remove(node.edges,edgeid)
					break
				end
			end
		end
	end
	
	MsgN("Specified vector "..tostring(vec).." not found in NodeMap.")
end



local function CheckEdges(Node,ClosedList,OpenList,ClosedCount,Count)
	local Dat = Node.edges
	
	for k = 1,ClosedCount do
		local v = ClosedList[k]
		
		for k2,v2 in pairs(Dat) do
			if (v == v2) then 
				remove(Dat,k2) 
				Node.edges_num = Node.edges_num-1
			end
			
			if (Node.edges_num <= 0) then return Dat end
		end
	end
	
	for k = 1,Count do
		local v = OpenList[k]
		
		for k2,v2 in pairs(Dat) do
			if (v == v2) then 
				remove(Dat,k2) 
				Node.edges_num = Node.edges_num-1
			end
			
			if (Node.edges_num <= 0) then return Dat end
		end
	end
	
	return Dat
end

local function AS_Reconstruct_Path(CheckNodes)
	local Path = {}
	local PathID = {}
	
	local Last = table.getn(CheckNodes)
	PathID[1] = Last

	local i=1
	while (PathID[i]>1) do
		i=i+1
		insert(PathID,i,CheckNodes[PathID[i-1]].par)
	end
	
	for n = table.getn(PathID),1,-1 do
		insert(Path,CheckNodes[PathID[n]])
	end
	
	return Path,CheckNodes
end

function AS_FindPath(nodeMap,startpos,endpos)
	--Yeah, we don't want to go about modifying the nodemap itself!
	nodeMap = table.Copy(nodeMap)
	
	--First, we find the closest node to startpos and endpos.
	--Should take O(n) time for this.
	local StartNode,StartDis
	local EndNode,EndDis
	
	for k,v in pairs(nodeMap) do
		v.g = 1000000
		v.h = 1000000
		
		if (!StartNode or v.pos:Distance(startpos) < StartDis) then 
			StartDis 	= v.pos:Distance(startpos)
			StartNode 	= v 
		end
		
		if (!EndNode or v.pos:Distance(endpos) < EndDis) then 
			EndDis 		= v.pos:Distance(endpos)
			EndNode 	= v 
		end
	end
	
	StartNode.g 	= 0
	StartNode.h 	= StartNode.pos:Distance(EndNode.pos)
	StartNode.f 	= StartNode.h
	StartNode.par 	= 1
	
	--Now for the real deal.
	--Open/Closed listing
	local ClosedList	= {}
	local OpenList 		= {StartNode}
	
	local Count			= 1
    local ClosedCount	= 0
	
	-- Base node stuff
	local TempG 	  = 0
	local RunTime	  = 0
	
	while (Count > 0 and RunTime < 9000) do
		RunTime = RunTime + 1
		
		local BaseID	  = 1 
		local LowFScore = OpenList[Count].f
		
		for k = 1,Count do
			local v = OpenList[k]
			
  		    if (v.f <= LowFScore) then
				LowFScore=v.f
				BaseID=k
			end
		end
		
		local CurrentNode = OpenList[BaseID]
		
		ClosedCount = ClosedCount+1
		ClosedList[ClosedCount] = CurrentNode
		
		local Dat = CheckEdges(CurrentNode,ClosedList,OpenList,ClosedCount,Count)
		
		for _,New in pairs(Dat) do
			New.h 	= New.pos:Distance(EndNode.pos)
			New.g 	= TempG+New.pos:Distance(CurrentNode.pos)
			New.f 	= TempG+New.h
			New.par = ClosedCount
			
			Count = Count+1
			OpenList[Count] = New
		end
		
		remove(OpenList,BaseID)
		Count = Count-1
		
		if (ClosedList[ClosedCount] == EndNode) then
			return AS_Reconstruct_Path(ClosedList) 
		end
	end
	
	return nil
end


--TESTING
if (SERVER) then
	util.AddNetworkString("TransmitNodeData")
	
	function AS_TransferNodeData(nodeMap,pl)
		if (!IsValid(pl)) then return end
		local num = #nodeMap
		
		net.Start("TransmitNodeData")
			net.WriteUInt(num,8)
			for k,v in pairs(nodeMap) do
				net.WriteVector(v.pos)
				net.WriteUInt(v.range,32)
			end
		net.Send(pl)
	end
else
	local Data = {}
	local Path = nil
	
	--TODO: MODIFY THIS TYLER
	net.Receive("TransmitNodeData",function()
		Data = {}
		for i = 1,net.ReadUInt(8) do
			AS_AddNode(Data,net.ReadVector(),net.ReadUInt(32))
		end
	end)
	
	concommand.Add("test_Add_astarnode",function(pl,cmd,arg)
		local tr = pl:GetEyeTrace()
		AS_AddNode(Data,tr.HitPos-tr.Normal*60,400)
	end)
	
	concommand.Add("test_astarnode",function(pl,cmd,arg)
		if (!Data[1]) then return end
		print("Computing path("..#Data.." nodes)")
		local t = SysTime()
		Path = AS_FindPath(Data,Data[1].pos,pl:GetEyeTrace().HitPos)
		print((SysTime()-t).." secs")
	end)
	
	local ang 	= Angle(0,0,0)
	local bbox 	= Vector(4,4,4)
	local mat 	= Material("models/debug/debugwhite")
	 
	hook.Add("PostDrawTranslucentRenderables","TestANode",function()
		render.SetMaterial(mat)
		
		for k,v in pairs(Data) do
			render.DrawBox( v.pos, ang, -bbox, bbox, MAIN_WHITECOLOR, true )
			
			for a,b in pairs(v.edges) do
				render.DrawLine( v.pos, b.pos, MAIN_WHITECOLOR, true )
			end
		end
		
		if (Path) then
			local Prev = nil
			for k,v in pairs(Path) do
				if (Prev) then render.DrawLine( v.pos, Prev, MAIN_REDCOLOR, true ) end
				Prev = v.pos
			end
		end
	end) 
end 