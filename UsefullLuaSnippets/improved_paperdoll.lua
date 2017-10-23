
local PPD = ClientsideModel("models/error.mdl")
PPD:SetNoDraw(true)

local meta = FindMetaTable("Player")

function meta:ApplyPPDModel(model,bone,pos,ang,scale)
	self.PPD = self.PPD or {}
	
	return table.insert(self.PPD,{
		Model = model,
		Bone = bone,
		Pos = pos,
		Ang = ang,
		Scale = scale
	})
end

function meta:ClearPPDModels()
	self.PPD = {}
end

function meta:RemovePPDModel(id)
	return table.remove(self.PPD,id)
end

function meta:GetPPDModels()
	return self.PPD or {}
end
		
 
hook.Add("PostPlayerDraw", "hatsss", function( ply )
	for k,v in pairs(ply:GetPPDModels()) do
		local Bone 				= ply:LookupBone(v.Bone)
		local BonePos , BoneAng = ply:GetBonePosition( Bone )
	
		PPD:SetModel(v.Model)
		PPD:SetRenderOrigin( BonePos )
		PPD:SetRenderAngles( BoneAng )
		
		local mat 	= Matrix()
		mat:Scale( v.Scale )
		mat:SetTranslation(v.Pos)
		mat:SetAngles(v.Ang)
		
		PPD:EnableMatrix( "RenderMultiply", mat )
		PPD:SetupBones()
		PPD:DrawModel()
	end
end)