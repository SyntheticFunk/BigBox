include('shared.lua')
function ENT:Draw() --Thanks wire holos!
				local count = self:GetBoneCount() or -1
                if count > 1 then
						self:SetModelScale(scalar, 0) --SetModelScale works perfectly for things with multiple animation bones, however, its
                else															 --totally useless for single boned things, it will shrink them absurdly.
                        local mat = Matrix()
                        mat:Scale( Vector( scale.y, scale.x, scale.z ) ) -- Note: We're swapping X and Y because RenderMultiply isn't consistent with the rest of source
                        self:EnableMatrix("RenderMultiply", mat)
                end

                local propmax = self:OBBMaxs()
                local propmin = self:OBBMins()
                self:SetRenderBounds(Vector(scale.x * propmax.x, scale.y * propmax.y, scale.z * propmax.z), Vector(scale.x * propmin.x, scale.y * propmin.y, scale.z * propmin.z))
			self:DrawModel()	--Render bounds fixes the clientside hitbox.
		end