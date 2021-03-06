--------------------------------------------------------------------------------
--
--								VARIABLES
--
--------------------------------------------------------------------------------
enable_battery = true -- Enable or disable the addon

battery = 100 -- Percentage at connection // Warning: If battery is disabled and set at 0 the player will cannot use his phone

is_baterry_in_charge = false

local autoCharge = 30 -- How many seconds it takes to the phone to charge without being used of 1%

local autoDischarge = 120 -- How many seconds it takes to the phone to discharge without being used of 1% // Default: 60 seconds
local DischargeInUse = 1 -- How many seconds it takes to the phone to discharge of 1%

local enable_charger_connection_sound = true -- Enable or disable
local enable_low_battery_sound = true -- Enable or disable

local charger_connected_volume = 0.15 -- 0 to 1 // Default: 0.15
local low_battery_volume = 0.15 -- 0 to 1 // Default: 0.15

local enable_charging_battery_message = true
local enable_empty_battery_message = true
local enable_low_battery_message = true

local charging_battery_message = "~g~~h~CHARGING BATTERY ~w~~h~(${battery}%)" -- Whatever you want | ${battery} = battery status
local low_battery_message = "~r~~h~LOW BATTERY (${battery}%)" -- Whatever you want | ${battery} = battery status
local empty_battery_message = "~r~~h~EMPTY BATTERY" -- Whatever you want | ${battery} = battery status

local lowSoundSent = 0
local chargeSoundSent = 0


--------------------------------------------------------------------------------
--
--								FUNCTIONS
--
--------------------------------------------------------------------------------
function updateBattery()
	if battery <= 15 and battery > 0 and battery % 5 == 0 then -- if Battery == Trigger low sound
		if is_baterry_in_charge then -- If player is charging
			if chargeSoundSent == 0 and enable_charger_connection_sound then
				SendNUIMessage({
					charging = true,
					chargerConnected = true,
					volume = charger_connected_volume,
					battery = battery
				})
				chargeSoundSent = 1
			else
				SendNUIMessage({
					charging = true,
					battery = battery
				})
			end
		elseif not is_baterry_in_charge then -- If player is not charging and low battery sound was not triggered
			if lowSoundSent == 0 and enable_low_battery_sound then
				SendNUIMessage({
					discharging = true,
					lowBattery = true,
					volume = low_battery_volume,
					battery = battery
				})
				lowSoundSent = 1
			else
				SendNUIMessage({
					discharging = true,
					battery = battery
				})
			end
		else
			SendNUIMessage({
				discharging = true,
				battery = battery
			})
		end
	elseif is_baterry_in_charge then -- If player charging
		if chargeSoundSent == 0 and enable_charger_connection_sound then
			SendNUIMessage({
				charging = true,
				chargerConnected = true,
				volume = charger_connected_volume,
				battery = battery
			})
			chargeSoundSent = 1
		else
			SendNUIMessage({
				charging = true,
				battery = battery
			})
		end
	else -- Else player discharging
		SendNUIMessage({
			discharging = true,
			battery = battery
		})
	end
	TriggerServerEvent('ephone:updateBattery', battery)
end

function drawTxt(x,y,scale, text, r,g,b,font)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function replaceBatteryField(string)
	return string.gsub(string, "${battery}", tostring(battery))
end

function getBattery()
	return battery
end


--------------------------------------------------------------------------------
--
--								BATTERY INFO
--
--------------------------------------------------------------------------------
Citizen.CreateThread(function()
	TriggerServerEvent('ephone:getBattery')
	--Citizen.Wait(1000)
    while true do Citizen.Wait(1)
		if enable_battery and enable_phone then
			updateBattery()
			if is_baterry_in_charge and enable_charging_battery_message then
				drawTxt(0.80, 0.96, 0.4, replaceBatteryField(charging_battery_message), 255, 255, 255, 0)
			elseif not is_baterry_in_charge then
				if battery <= 15 and battery > 0 and enable_low_battery_message then
					drawTxt(0.82, 0.96, 0.4, replaceBatteryField(low_battery_message), 255, 255, 255, 0)
				elseif battery == 0 and enable_empty_battery_message then
					drawTxt(0.82, 0.96, 0.4, replaceBatteryField(empty_battery_message), 255, 255, 255, 0)
				end
			end
		end
    end
end)


--------------------------------------------------------------------------------
--
--								BATTERY CHARGING
--
--------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while enable_battery do Citizen.Wait(autoCharge * 1000)
        if is_baterry_in_charge and (battery <= 100) then
			if battery < 100 then
				battery = battery + 1
			end
			chargeSoundSent = 1
		else
			chargeSoundSent = 0
        end
    end
end)


--------------------------------------------------------------------------------
--
--								BATTERY DISCHARGING
--
--------------------------------------------------------------------------------
Citizen.CreateThread(function()
	local counter = 0
    while enable_battery do Citizen.Wait(1)
		if showPhone and battery > 0 then
			Citizen.Wait(1000)
			counter = counter + 1
			if (counter > DischargeInUse) then
				battery = battery - 1
				lowSoundSent = 0
				counter = 0
			end
		end
    end
end)

Citizen.CreateThread(function()
    while true do Citizen.Wait(autoDischarge * 1000)
		if enable_battery and battery > 0 then
			battery = battery - 1
			lowSoundSent = 0
		end
    end
end)


--------------------------------------------------------------------------------
--
--									EVENTS
--
--------------------------------------------------------------------------------
RegisterNetEvent("ephone:loadBattery")
AddEventHandler("ephone:loadBattery", function(nb)
	battery = nb
end)

RegisterNetEvent("ephone:battery_in_charge")
AddEventHandler("ephone:battery_in_charge", function()
	is_baterry_in_charge = true
end)

RegisterNetEvent("ephone:battery_not_in_charge")
AddEventHandler("ephone:battery_not_in_charge", function ()
	is_baterry_in_charge = false
end)

RegisterNetEvent("ephone:set_battery")
AddEventHandler("ephone:set_battery", function (to)
	if to >= 0 and to <= 100 then
		battery = to
	else
		Citizen.Trace("ERROR ePhone: Trying to set battery under 0 or above 100.")
	end
end)
