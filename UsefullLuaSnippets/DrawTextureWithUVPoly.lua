local DrawPoly = surface.DrawPoly

function DrawTextureUV(x,y,w,h,PolyHighlights,tColor,iMaterial)
	PolyHighlights = PolyHighlights or {}
	
	surface.SetMaterial(iMaterial)
	surface.DrawTexturedRect(x,y,w,h)
	
	draw.NoTexture()
	surface.SetDrawColor(tColor.r,tColor.g,tColor.b,tColor.a)
	
	for PolyID,PolyData in pairs(PolyHighlights) do
		local Vertexes = {}
		local iter = 0
		
		for k,v in pairs(PolyData) do
			iter = iter+1
			
			local X = x + v.u * w
			local Y = y + v.v * h
			
			Vertexes[iter] = {x=X,y=Y}
		end
			
		DrawPoly(Vertexes)
	end
end