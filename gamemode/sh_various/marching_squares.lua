/*
	IMPLEMENTATION BY STARLIGHT
*/

/*
TriangulateSquare = {
	[0] = function(square)
		return nil
	end,
	-- 1 point
	[1] = function(square)
		return {square.bottomCenter, square.bottomLeft, square.middleLeft}
	end,
	[8] = function(square)
		return {square.bottomRight, square.bottomCenter, square.middleRight}
	end,
	[4] = function(square)
		local tri = {}
		return {square.topCenter, square.topRight, square.middleRight}
	end,
	[2] = function(square)
		return {square.topLeft, square.topCenter, square.middleLeft}
	end,
	-- 2 points
	[9] = function(square)
		return {square.middleRight, square.bottomRight, square.bottomLeft, square.middleLeft}
	end,
	[12] = function(square)
		return {square.topCenter, square.topRight, square.bottomRight, square.bottomCenter }
	end,
	[3] = function(square)
		return {square.topLeft, square.topCenter, square.bottomCenter, square.bottomLeft}
	end,
	[6] = function(square)
		return {square.topLeft, square.topRight, square.middleRight, square.middleLeft}
	end,
	[5] = function(square)
		return {square.topCenter, square.topRight, square.middleRight, square.bottomCenter, square.bottomLeft, square.middleLeft}
	end,
	[10] = function(square)
		return {square.topLeft, square.topCenter, square.middleRight, square.bottomRight, square.bottomCenter, square.middleLeft}
	end,
	-- 3 points
	[13] = function(square)
		return {square.topCenter, square.topRight, square.bottomRight, square.bottomLeft, square.middleLeft}
	end,
	[11] = function(square)
		return {square.topLeft, square.topCenter, square.middleRight, square.bottomRight, square.bottomLeft}
	end,
	[7] = function(square)
		return {square.topLeft, square.topRight, square.middleRight, square.bottomCenter, square.bottomLeft}
	end,
	[14] = function(square)
		return {square.topLeft, square.topRight, square.bottomRight, square.bottomCenter, square.middleLeft}
	end,

	-- 4 points
	[15] = function(square)
		return {square.topLeft, square.topRight, square.bottomRight, square.bottomLeft}
	end,
}

function HandleTri(tbl)
	local tris = {}
	local length = #tbl
	if length >= 3 then
		tris[#tris + 1] = {tbl[1], tbl[2], tbl[3]}
	end
	if length >= 4 then
		tris[#tris + 1] = {tbl[1], tbl[3], tbl[4]}
	end
	if length >= 5 then
		tris[#tris + 1] = {tbl[1], tbl[4], tbl[5]}
	end
	if length >= 6 then
		tris[#tris + 1] = {tbl[1], tbl[5], tbl[6]}
	end
	return tris
end

function CalculateMesh(mesh, z, min)
	z = z || 0
	min = min || 0
	local vertexs = {}
	local byted = nil
	local points = {}

	for x, yTbl in pairs(mesh) do
		if x == min then continue end
		for y, bool in pairs(yTbl) do

			local square = {
				bottomRight = {x = x-1, y = y-1},
				bottomLeft = {x = x, y = y -1},
				bottomCenter = {x = x - 0.5, y = y -1},
				topRight = { x = x -1, y = y},
				topLeft = {x = x, y = y},
				topCenter = {x = x - 0.5, y = y },
				middleRight = { x = x-1, y = y - 0.5},
				middleCenter = {x = x - 0.5, y = y - 0.5},
				middleLeft = {x = x, y = y - 0.5},
			}

			if y == min  then continue end
			local byte = tonumber( tostring(mesh[x-1][y-1]) .. tostring(mesh[x-1][y]) .. tostring(mesh[x][y]) .. tostring(mesh[x][y-1]), 2)
			byted = byte
			if !TriangulateSquare[byte] then
			end

			local ignore = {
				--[15] = true,
				[0] = true,
			}

			if  !ignore[byte] then

			else
				continue
			end

			local tri = TriangulateSquare[byte](square)
			if tri then
				local triTbl = HandleTri(tri)
				for index, vertexs in ipairs(triTbl) do
					for index, vertex in pairs(vertexs) do
						points[#points + 1] = {
							x = vertex.x,
							y = vertex.x,
							pos = Vector(vertex.x, vertex.y, z),
							u = 0,
							v = 0,
							normal = Vector(0,0, 1),
						}
					end
				end
			end
		end
	end

	return points, byted
end


if SERVER then return end

mesh = mesh || nil

local points = {}
local tbl2 = {}
concommand.Add("test_mesh_make", function()
	local tbl = {}
	for x = -10, 10 do
		tbl[x] = {}
		for y = -10, 10 do
			if math.abs(x) == 10 or math.abs(y) == 10 then
				if math.abs(x) == 10 and math.abs(y) == 10  then
					tbl[x][y] = 0
				else
					tbl[x][y] = 1
				end
			else
				tbl[x][y] = ( (x^2 < 10 or  y^2 > 10 ) and 1) or 0
			end
		end
	end

	local tris, byte = CalculateMesh(tbl, 0, -10)
	points = tris
	tbl2 = tbl
	mesh = Mesh()
	mesh:BuildFromTriangles(tris)
end)

concommand.Add("derma_attempt", function()
	local pnl = vgui.Create("DFrame")
	pnl:MakePopup()
	pnl:SetSize(256, 256)
	pnl:Center()

	local buttons = {}

	local doClick = function(self)
		self.Active = !self.Active
		-- 6
		-- 9

		local tbl = {}
		tbl[1] = {}
		tbl[2] = {}
		tbl[1][1] = (buttons[1].Active and 1) or 0
		tbl[1][2] = (buttons[2].Active and 1) or 0
		tbl[2][1] = (buttons[4].Active and 1) or 0
		tbl[2][2] = (buttons[3].Active and 1) or 0

		local tris, byte = CalculateMesh(tbl, 0, 1)

		points = tris
		mesh = Mesh()
		mesh:BuildFromTriangles(tris)

		for index, but in ipairs(buttons) do
			but:SetText(byte)
		end

	end
	for x = 1, 4 do
		buttons[x] = vgui.Create("DButton", pnl)
		buttons[x]:SetSize(64, 64)

		local rot = math.rad( x * 90 + 45 + 90)
		if x == 1 then
			buttons[x]:SetPos(0, 15)
		elseif x == 2 then
			buttons[x]:SetPos(256-64, 16)
		elseif x == 3 then
			buttons[x]:SetPos(0, 256-64)
		elseif x == 4 then
			buttons[x]:SetPos(256-64, 256-64)
		end


		buttons[x].DoClick = doClick
		buttons[x]:SetText(x)
		buttons[x].Paint = function(self, w, h)
			surface.SetDrawColor(color_white)
			surface.DrawRect(0,0, w, h)
			if self.Active then
				surface.SetDrawColor(color_black)
				surface.DrawRect(w/4, h/4, w/4, h/4)
			end
		end
	end
end)


hook.Add( "PostDrawTranslucentRenderables", "test", function( bDepth, bSkybox )

	-- If we are drawing in the skybox, bail
--[[	if ( bSkybox ) then return end
	if mesh then
		render.SetColorMaterial()
		render.SetMaterial(Material("starcolor"))
		mesh:Draw()
		local mesh = tbl2
	end]]--
end)
*/