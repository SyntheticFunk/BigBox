------------------------------------
--	Simple Prop Protection
--	By Spacetech, ported by Donkie with authorization for gmod 13.
-- 	http://code.google.com/p/simplepropprotection
------------------------------------

--I needed a prop protection, more specifically I needed CPPI, and this was what I used to use, so that's what got implemented. 
--It doesn't need to be included in the gamemode, but I decided what the hell it's what I was going to use anyway. Take it out if you want, any prop protection works.
--TO SPACETECH: I'm sorry for not asking if I could use this... I noticed it was updated by someone so I concluded it was abandonware. Let me know if you want it out.

AddCSLuaFile("sh_SPropProtection.lua")
AddCSLuaFile("cl_Init.lua")
AddCSLuaFile("sh_CPPI.lua")

SPropProtection = {}
SPropProtection.Version = 1.6 -- "SVN"

CPPI = {}
CPPI_NOTIMPLEMENTED = 26
CPPI_DEFER = 16

include("sh_CPPI.lua")

if(SERVER) then
	include("sv_Init.lua")
else
	include("cl_Init.lua")
end

Msg("==========================================================\n")
Msg("Simple Prop Protection Version "..SPropProtection.Version.." by Spacetech has loaded\n")
Msg("==========================================================\n")
