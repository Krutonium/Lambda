include("huds/hud_numeric.lua")
include("huds/hud_suit.lua")
include("huds/hud_pickup.lua")
include("huds/hud_roundinfo.lua")
include("huds/hud_settings.lua")
include("huds/hud_hint.lua")
include("huds/hud_crosshair.lua")

--local DbgPrint = GetLogging("HUD")

DEFINE_BASECLASS( "gamemode_base" )

local function AskWeapon(ply, hud, wep)
	if IsValid( wep ) and wep.HUDShouldDraw ~= nil then
		return wep.HUDShouldDraw( wep, name )
	end
end

local hidehud = GetConVar("hidehud")

function GM:HUDInit()

	if IsValid(self.HUDSuit) then
		self.HUDSuit:Remove()
	end

	if IsValid(self.HUDRoundInfo) then
		self.HUDRoundInfo:Remove()
	end

	self.HUDRoundInfo = vgui.Create("HUDRoundInfo")
	self.HUDSuit = vgui.Create("HudSuit")

end

function GM:HUDTick()

	local ply = LocalPlayer()
	if not IsValid(ply) then
		return
	end

	-- FIXME: Show the hud only when in color customization.
	local hideHud = false

	local wep = ply:GetActiveWeapon()
	local CHudHealth = (not wep:IsValid() or AskWeapon(ply, "CHudHealth", wep) ~= false) and hook.Call("HUDShouldDraw", nil, "CHudHealth") ~= false and not hideHud
	local CHudBattery = (not wep:IsValid() or AskWeapon(ply, "CHudBattery", wep) ~= false) and hook.Call("HUDShouldDraw", nil, "CHudBattery") ~= false and not hideHud
	local CHudSecondaryAmmo = (wep:IsValid() and AskWeapon(ply, "CHudSecondaryAmmo", wep) ~= false) and hook.Call("HUDShouldDraw", nil, "CHudSecondaryAmmo") ~= false and not hideHud

	local drawHud = ply:IsSuitEquipped() and ply:Alive() and hidehud:GetBool() ~= true

	if IsValid(self.HUDSuit) then

		local vehicle = ply:GetVehicle()

		local suit = self.HUDSuit
		suit.HUDHealth:SetVisible(CHudHealth and drawHud)
		suit.HUDArmor:SetVisible(CHudBattery and drawHud)
		suit.HUDAux:SetVisible(CHudBattery and drawHud)
		suit.HUDAmmo:SetVisible(CHudSecondaryAmmo and IsValid(wep) or IsValid(vehicle) and drawHud)

		suit:SetVisible(drawHud)

	end

end

function GM:HUDShouldDraw( hudName )

	local ply = LocalPlayer()
	if not IsValid(ply) then
		return false
	end

	local viewlock = ply:GetViewLock()

	if hidehud:GetBool() == true then
		return false
	end

	if hudName == "CHudCrosshair"  then
		if self:ShouldDrawCrosshair() == false then
			return false
		end
		if lambda_crosshair:GetBool() == true then
			local wep = ply:GetActiveWeapon()
			if wep and wep.DoDrawCrosshair == nil then
				return false
			end
		end
	elseif hudName == "CHudGeiger" then
		if not ply:IsSuitEquipped() then
			return false
		end
	elseif hudName == "CHudBattery" then
		return false
	elseif hudName == "CHudHealth" or
		hudName == "CHudAmmo" or
		hudName == "CHudSecondaryAmmo" then
		return false
	elseif hudName == "CHudDamageIndicator" then
		-- We include the lifetime because theres some weird thing going with the damage indicator.
		if ply:Alive() == false or ply:GetLifeTime() < 1.0 then
			return false
		end
	elseif hudName == "CHudHistoryResource" then
		return false
	end

	return true

end

function GM:HUDPaint()

	hook.Run( "HUDDrawPickupHistory" )
	hook.Run( "HUDDrawHintHistory" )
	hook.Run( "DrawDeathNotice", 0.85, 0.04 )

	if lambda_crosshair:GetBool() == true and self:ShouldDrawCrosshair() == true then
		hook.Run( "DrawDynamicCrosshair" )
	end

end

function GM:SetRoundDisplayInfo(infoType, params)
	if not IsValid(self.HUDRoundInfo) then
		return
	end
	self.HUDRoundInfo:SetVisible(true)
	self.HUDRoundInfo:SetDisplayInfo(infoType, params)
end
