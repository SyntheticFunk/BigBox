ENT.Type = "anim"
ENT.Base = "base_entity"
 
ENT.PrintName		= "100% unadulterated prop_physics"
ENT.Author			= "Diggz"
ENT.Contact			= "steam URL /diggz"
ENT.Purpose			= "Its a prop_physics!"
ENT.Instructions	= "Potential side effects may vary."
ENT.Spawnable 		= false

function ENT:Initialize()
		--First we shrink the prop on the server
		--So to start off, initialize normal physics so we can get our mesh vertices
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )


		--Next, we store a local variable filled with the initial vertices
		local phys	= self:GetPhysicsObject()
		local convexes	= phys:GetMeshConvexes()
		local mass 	= phys:GetMass()		
		--Begin the clipping procedures, GetMeshConvexes returns vertices' coordinates as local vectors in relation
		--to the model origin, therefore we need to simply multiply each individual convex's local vector by a scalar

		local miniconvexes = {}
		for i, convex in ipairs( convexes ) do
			miniconvexes[i] = {}
			for j, vertex in ipairs( convex ) do
				miniconvexes[i][j] = vertex.pos * scalar
			end
		end

		--Then we reinitialize our new clipped physics

		self:PhysicsInitMultiConvex( miniconvexes ) 

		--Then we enable custom collisions, unsure if it is actually as self explanatory as it seems
		self:EnableCustomCollisions( true )	
		self:GetPhysicsObject():SetMass( mass )	
		self:SetCollisionGroup( COLLISION_GROUP_NONE )
		self:Activate()
end