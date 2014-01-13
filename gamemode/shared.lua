--Feel free to use this code as you see fit, my only request is that if you make any improvements to it, or add anything cool, please give me a copy.
GM.Name		= "Size Test"
GM.Author	= "Digglewiggle"
GM.Email	= "funkadelicosmonaut@gmail.com"
GM.Website	= "http://steamcommunity.com/id/Diggz/"

DeriveGamemode( "sandbox" )
--Constants, in others words, change how broken you want your game to be here.
GM.IsSandboxDerived = true
scale = Vector( 1/8, 1/8, 1/8 )
scalar = 1/8

--Props
local function GoAhead( class ) --Used to help decide whether or not to not fuck with something.
	local tab = {}
	tab = scripted_ents.GetList()
	local result = false
	for k, v in pairs( tab ) do
		if class == k and class ~= "gmod_wire_hologram" and class ~= "sent_prop" then
			result = true
			break
		end
	end
	return result
end
local function CopyGenericData( ply, A, B ) --Duplicator wizardry, at one time it was thought to be an incarnate of GabeN himself. Deds to MDave
	 data = duplicator.CopyEntTable( A )
		data.PhysicsObjects = nil
	B.EntityMods = data.EntityMods
	duplicator.DoGeneric( B, data )
	duplicator.ApplyEntityModifiers( ply, B )
	if IsValid( ply ) then
		SPropProtection.PlayerMakePropOwner(ply, B)
	end
end

local function BigShrink( ent )
local class = ent:GetClass() 
local good = GoAhead( class )
	if ( class == "prop_physics" ) then
		timer.Simple( 0, function() --OnEntityCreated is called before an entity's physobject even exists, thus a 0 second timer allows us to run
		if IsValid(ent:GetPhysicsObject()) then -- on the tick thereafter. 
			local prop = nil
			local owner = ent:CPPIGetOwner() --This shit right here is why SPP is integrated.
			-- Create new entity
			local motion = ent:GetPhysicsObject():IsMotionEnabled()
			prop = ents.Create( "sent_prop" )			
			CopyGenericData( owner, ent, prop ) --Wizardry at its finest.
			prop:Spawn()
			
			local phys = prop:GetPhysicsObject()
			phys:EnableMotion( motion )
			phys:Wake()
			
			undo.ReplaceEntity( ent, prop )
			cleanup.ReplaceEntity( ent, prop )
			ent:Remove()
			end
		end)
	elseif good or ( class == "prop_vehicle_prisoner_pod" ) then
		timer.Simple( 0, function()
		if IsValid( ent:GetPhysicsObject() ) then --Note we do not need to initialize physics as everything thats going to move already initializes itself.
			
			ent:PhysicsInit( SOLID_BBOX )
			ent:SetMoveType(MOVETYPE_VPHYSICS)
			
			local phys	= ent:GetPhysicsObject()
			local convexes	= phys:GetMeshConvexes()
			local mass 	= phys:GetMass()	

			local miniconvexes = {}					--A more detailed description lies within the sent_prop's lua.
			for i, convex in ipairs( convexes ) do
				miniconvexes[i] = {}
				for j, vertex in ipairs( convex ) do
					miniconvexes[i][j] = vertex.pos * scalar * 0.9
				end
			end

			ent:PhysicsInitMultiConvex( miniconvexes ) 

			ent:EnableCustomCollisions( true ) 
			ent:GetPhysicsObject():SetMass( mass )	
			ent:SetCollisionGroup( COLLISION_GROUP_NONE)
			ent:Activate()
			
		end
		end)
			local count = ent:GetBoneCount() or -1
			if CLIENT then
				if not (count > 1) then	--SetModelScale works perfectly for things with multiple animation bones, however, its
					local mat = Matrix()	--totally useless for single boned things, it will shrink them absurdly.
					mat:Scale( scale ) --Swapping the X and Y axes of the matrix isn't really required when they're identical.
					ent:EnableMatrix("RenderMultiply", mat)
				else ent:SetModelScale(scalar, 0) 
				end
			
				local propmax = ent:OBBMaxs()
				local propmin = ent:OBBMins()
				ent:SetRenderBounds(propmin, propmax)
				ent:DrawModel()
			end 
	end
end

hook.Add( "OnEntityCreated", "Bigbox_PropShrink", BigShrink )

local function BSpawn( ply ) --Player Resizing, I recommend also using phys_timescale 0.85, everything seems faster otherwise.

	ply:SetModelScale(scalar, 0)
	ply:SetHull( Vector( -16, -16, 0 )*scalar, Vector( 16, 16, 72)*scalar ) --Original Vecs are Vector( -16, -16, 0 ), Vector( 16, 16, 72 )
	ply:SetHullDuck( Vector( -16, -16, 0 )*scalar, Vector( 16, 16, 36)*scalar ) --Original is Vector( -16, -16, 0 ), Vector( 16, 16, 36 )
	ply:SetViewOffset( Vector( 0, 0, 64 )*scalar ) --Original is Vector( 0, 0, 64 )
	ply:SetViewOffsetDucked( Vector( 0, 0, 28 )*scalar ) -- Original is Vector( 0, 0, 28 )
	ply:SetNetworkedFloat("PlViewOffset",scalar)
	timer.Simple(0.25, function()
		ply:SetJumpPower( 100 ) --Default is 200
		ply:SetWalkSpeed( 45 ) --Default is 250
		ply:SetRunSpeed( 90 ) --Default is 500
		ply:SetStepSize( 18*scalar/1.25 ) --Default is 18
	end)
end

hook.Add( "PlayerSpawn", "Bigbox_Spawn", BSpawn )

local function Tick( )

	if CLIENT then
		local k, v
		
		for k, v in pairs( player.GetAll( ) ) do --Though I loathe to do so, it's pretty much required to run this every tick.
	
      		v:SetModelScale( (scalar), 0)
   			v:SetRenderBounds( Vector( -16, -16, 0 )*scalar, Vector( 16, 16, 72)*scalar )			

   			v:SetViewOffset( Vector( 0, 0, 64 )*scalar )
   			v:SetViewOffsetDucked( Vector( 0, 0, 28 )*scalar )
  
   			--v:SetHull( Vector( -16, -16, 0 )*scalar, Vector( 16, 16, 72)*scalar ) )
			v:SetHull( Vector( -16, -16, 0 )*scalar, Vector( 16, 16, 72)*scalar )
   			v:SetHullDuck( Vector( -16, -16, 0 )*scalar, Vector( 16, 16, 36)*scalar )		

         end	
end--[[		 Part of the Old Wiremod Client-trace workaround
	else
		for k, v in pairs( player.GetAll() ) do --This is the workaround for wire and ACF entities being bullshit.
			local ent = v:GetEyeTrace().Entity --TODO: Make this run every half second.. Or second...
			v:SetNetworkedEntity( "test", ent ) 
		end
 end]]--
end

hook.Add( "Tick", "BigBox_Clientside", Tick )    
 

 


local function bigBoxCalcAbsolutePosition(self) --Wizardry. This function disables prediction and then "fakes" it. Deds to MDave.
        local phys = self:GetPhysicsObject()
       
        if IsValid( phys ) then
                phys:SetPos( self:GetPos() )
                phys:SetAngles( self:GetAngles() ) --We're essentially forcing the client to update the props location
													--In theory, removing the clients need to calculate prop physics should also reduce lag.
                phys:EnableMotion( false )    --This is what actually turns off prediction
        end					
end
--[[ Old Wiremod Client-trace workaround
local function bigBoxIsLookedAt(self) --Something to do with Wire-esque SENTs disables their collision with client-side traces.
	local ply = LocalPlayer()			--Don't look at me for a fix, my SENTs work fine.
	local lookedat = ply:GetNetworkedEntity("test") --My only regret is that the wire advanced stool doesn't work with this patch.
	if ( lookedat != self ) or ( lookedat == nil ) then return false end
	if ( ply:GetPos():Distance( self:GetPos() ) > 256 ) then return false end
	return true
	
end
]]--
local function bigBoxUpdateTransmitState() --While we're replacing everything with SENTs, we may as well make everything as efficient as possible.
		return TRANSMIT_PVS			--PVS causes props to act as if occluded when not onscreen, removing lag from stuff you aren't looking at.
end
      
local oldRegister = scripted_ents.Register --This is wizardry too. Deds to Donovan, the glorious bastard that he is.
scripted_ents.Register = function( array, name) --Using this to override ENT: functions for every spawned scripted entity without having to edit them.
	if CLIENT then								--Pretty much what happens when you combine laziness and brilliance.
		array.CalcAbsolutePosition = bigBoxCalcAbsolutePosition
	--	array.BeingLookedAtByLocalPlayer = bigBoxIsLookedAt -- Old Wiremod Workaround
	else
		array.UpdateTransmitState = bigBoxUpdateTransmitState
	end
    oldRegister( array, name )      
end