local sellAnywhere = true
local useBlip = true
local salesYard = vector3(178.38,-1150.32,29.30)
local salesRadius = 20.0

PT = {}
PT.Game = {}
PT.Math = {}
ServerCallbacks = {}
CurrentRequestId = 0

function TriggerServerCallback(name, cb, ...)
	ServerCallbacks[CurrentRequestId] = cb

	TriggerServerEvent('triggerServerCallback', name, CurrentRequestId, ...)

	if CurrentRequestId < 65535 then
		CurrentRequestId = CurrentRequestId + 1
	else
		CurrentRequestId = 0
	end
end

RegisterNetEvent('serverCallback')
AddEventHandler('serverCallback', function(requestId, ...)
	ServerCallbacks[requestId](...)
	ServerCallbacks[requestId] = nil
end)

NewEvent = function(net,func,name,...)
  if net then RegisterNetEvent(name); end
  AddEventHandler(name, function(...) func(source,...); end)
end

function PT.Game.GetVehicleProperties(vehicle)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		local neonvrp = table.pack(GetVehicleNeonLightsColour(vehicle))
		local smokecolor = table.pack(GetVehicleTyreSmokeColor(vehicle))
		local extras = {}

		for extraId=0, 12 do
			if DoesExtraExist(vehicle, extraId) then
				local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
				extras[tostring(extraId)] = state
			end
		end

		if IsToggleModOn(vehicle,18) then
			turbo = "on"
		else
			turbo = "off"
		end
		if IsToggleModOn(vehicle,20) then
			tiresmoke = "on"
		else
			tiresmoke = "off"
		end
		if IsToggleModOn(vehicle,22) then
			xenon = "on"
		else
			xenon = "off"
		end
		if IsVehicleNeonLightEnabled(vehicle,0) then
			neon0 = "on"
		else
			neon0 = "off"
		end
		if IsVehicleNeonLightEnabled(vehicle,1) then
			neon1 = "on"
		else
			neon1 = "off"
		end
		if IsVehicleNeonLightEnabled(vehicle,2) then
			neon2 = "on"
		else
			neon2 = "off"
		end
		if IsVehicleNeonLightEnabled(vehicle,3) then
			neon3 = "on"
		else
			neon3 = "off"
		end
		if GetVehicleTyresCanBurst(vehicle) then
			bulletproof = "off"
		else
			bulletproof = "on"
		end
		if GetVehicleModVariation(vehicle,23) then
			variation = "on"
		else
			variation = "off"
		end

		return {
			model             = GetEntityModel(vehicle),
			model2			  = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),

			plate             = PT.Math.Trim(GetVehicleNumberPlateText(vehicle)),
			plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

			bodyHealth        = PT.Math.Round(GetVehicleBodyHealth(vehicle), 1),
			engineHealth      = PT.Math.Round(GetVehicleEngineHealth(vehicle), 1),
			tankHealth        = PT.Math.Round(GetVehiclePetrolTankHealth(vehicle), 1),

			turbo 			  = turbo,
			tiresmoke 		  = tiresmoke,
			xenon 			  = xenon,
			neon0  			  = neon0,
			neon1  			  = neon1,
			neon2  			  = neon2,
			neon3  			  = neon3,
			bulletproof  	  = bulletproof,

			fuelLevel         = PT.Math.Round(GetVehicleFuelLevel(vehicle), 1),
			dirtLevel         = PT.Math.Round(GetVehicleDirtLevel(vehicle), 1),
			color1            = colorPrimary,
			color2            = colorSecondary,

			pearlescentColor  = pearlescentColor,
			wheelColor        = wheelColor,

			wheels            = GetVehicleWheelType(vehicle),
			windowTint        = GetVehicleWindowTint(vehicle),
			xenonColor        = GetVehicleXenonLightsColour(vehicle),

			neonEnabled       = {
				IsVehicleNeonLightEnabled(vehicle, 0),
				IsVehicleNeonLightEnabled(vehicle, 1),
				IsVehicleNeonLightEnabled(vehicle, 2),
				IsVehicleNeonLightEnabled(vehicle, 3)
			},

			neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
			neoncolor1        = neonvrp[1],
			neoncolor2        = neonvrp[2],
			neoncolor3        = neonvrp[3],
			extras            = extras,
			tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),
			smokecolor1		  = smokecolor[1],
			smokecolor2		  = smokecolor[2],
			smokecolor3		  = smokecolor[3],
			variation		  = variation,

			modSpoilers       = GetVehicleMod(vehicle, 0),
			modFrontBumper    = GetVehicleMod(vehicle, 1),
			modRearBumper     = GetVehicleMod(vehicle, 2),
			modSideSkirt      = GetVehicleMod(vehicle, 3),
			modExhaust        = GetVehicleMod(vehicle, 4),
			modFrame          = GetVehicleMod(vehicle, 5),
			modGrille         = GetVehicleMod(vehicle, 6),
			modHood           = GetVehicleMod(vehicle, 7),
			modFender         = GetVehicleMod(vehicle, 8),
			modRightFender    = GetVehicleMod(vehicle, 9),
			modRoof           = GetVehicleMod(vehicle, 10),

			modEngine         = GetVehicleMod(vehicle, 11),
			modBrakes         = GetVehicleMod(vehicle, 12),
			modTransmission   = GetVehicleMod(vehicle, 13),
			modHorns          = GetVehicleMod(vehicle, 14),
			modSuspension     = GetVehicleMod(vehicle, 15),
			modArmor          = GetVehicleMod(vehicle, 16),

			modTurbo          = IsToggleModOn(vehicle, 18),
			modSmokeEnabled   = IsToggleModOn(vehicle, 20),
			modXenon          = IsToggleModOn(vehicle, 22),

			modFrontWheels    = GetVehicleMod(vehicle, 23),
			modBackWheels     = GetVehicleMod(vehicle, 24),

			modPlateHolder    = GetVehicleMod(vehicle, 25),
			modVanityPlate    = GetVehicleMod(vehicle, 26),
			modTrimA          = GetVehicleMod(vehicle, 27),
			modOrnaments      = GetVehicleMod(vehicle, 28),
			modDashboard      = GetVehicleMod(vehicle, 29),
			modDial           = GetVehicleMod(vehicle, 30),
			modDoorSpeaker    = GetVehicleMod(vehicle, 31),
			modSeats          = GetVehicleMod(vehicle, 32),
			modSteeringWheel  = GetVehicleMod(vehicle, 33),
			modShifterLeavers = GetVehicleMod(vehicle, 34),
			modAPlate         = GetVehicleMod(vehicle, 35),
			modSpeakers       = GetVehicleMod(vehicle, 36),
			modTrunk          = GetVehicleMod(vehicle, 37),
			modHydrolic       = GetVehicleMod(vehicle, 38),
			modEngineBlock    = GetVehicleMod(vehicle, 39),
			modAirFilter      = GetVehicleMod(vehicle, 40),
			modStruts         = GetVehicleMod(vehicle, 41),
			modArchCover      = GetVehicleMod(vehicle, 42),
			modAerials        = GetVehicleMod(vehicle, 43),
			modTrimB          = GetVehicleMod(vehicle, 44),
			modTank           = GetVehicleMod(vehicle, 45),
			modWindows        = GetVehicleMod(vehicle, 46),
			modLivery         = GetVehicleLivery(vehicle)
		}
	else
		return
	end
end

function PT.Math.Round(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

function PT.Math.Trim(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

local TSC = TriggerServerCallback
local TSE = TriggerServerEvent
local isConfirming = false
local forSale = {}

function GetVecDist(v1,v2)
  if not v1 or not v2 or not v1.x or not v2.x then return 0; end
  return math.sqrt(  ( (v1.x or 0) - (v2.x or 0) )*(  (v1.x or 0) - (v2.x or 0) )+( (v1.y or 0) - (v2.y or 0) )*( (v1.y or 0) - (v2.y or 0) )+( (v1.z or 0) - (v2.z or 0) )*( (v1.z or 0) - (v2.z or 0) )  )
end

function DrawText3D(x,y,z, text, scaleB)
  if not scaleB then scaleB = 1; end
  local onScreen,_x,_y = World3dToScreen2d(x,y,z)
  local px,py,pz = table.unpack(GetGameplayCamCoord())
  local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
  local scale = (((1/dist)*2)*(1/GetGameplayCamFov())*100)*scaleB

  if onScreen then
    -- Formalize the text
    SetTextColour(220, 220, 220, 255)
    SetTextScale(0.0*scale, 0.40*scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(true)

    -- Diplay the text
    SetTextEntry("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(_x, _y)
  end
end

Citizen.CreateThread(function(...)
  TSC('MF_VehSales:GetStartData', function(retVal,retTab) dS = true; cS = retVal; forSale = retTab; end)
  while not cS or not dS or not forSale do Citizen.Wait(0); end
  local lastPlate = 'SUKDIK'
  local drawText = 'YUTU'
  local lastTimer = GetGameTimer()
  if not sellAnywhere and useBlip then
    local blip = AddBlipForCoord(salesYard.x, salesYard.y, salesYard.z)
    SetBlipSprite               (blip, 225)
    SetBlipDisplay              (blip, 3)
    SetBlipScale                (blip, 1.0)
    SetBlipColour               (blip, 71)
    SetBlipAsShortRange         (blip, false)
    SetBlipHighDetail           (blip, true)
    BeginTextCommandSetBlipName ("STRING")
    AddTextComponentString      ("Carros usados")
    EndTextCommandSetBlipName   (blip)
  end
  while true do
    Citizen.Wait(0)
    local closest,closestDist
    local plyPos = GetEntityCoords(GetPlayerPed(-1))
    for k,v in pairs(forSale) do
      local dist = GetVecDist(plyPos,v.loc)
      if not closestDist or dist < closestDist then
        closestDist = dist
        closest = v
      end
    end
    if closestDist and closestDist < 10 then
	  TriggerServerCallback("pt-venderveiculo:ident",function (user_owner, user_id)
        if not lastPlate or closest.vehProps.plate ~= lastPlate then
          isConfirming = false
          if user_owner ~= user_id then
            drawText = "[~r~"..GetDisplayNameFromVehicleModel(closest.vehProps.model).."~s~] Press [~r~E~s~] to buy [$~r~"..closest.price.."~s~]"
          else
            drawText = "[~r~"..GetDisplayNameFromVehicleModel(closest.vehProps.model).."~s~] Press [~r~E~s~] to recover the vehicle [$~r~"..closest.price.."~s~]"
          end
          local turbs = 'No'
          if closest.vehProps.turbo == "on" then turbs = 'Yes'; end
          drawTextB = "[Turbo : ~r~"..turbs.."~s~] [Motor : ~r~"..tostring(closest.vehProps.modEngine).."~s~] [Gear Box : ~r~"..tostring(closest.vehProps.modTransmission).."~s~]"
          drawTextC = "[Suspension : ~r~"..tostring(closest.vehProps.modSuspension).."~s~] [Armor : ~r~"..tostring(closest.vehProps.modArmor).."~s~] [Brakes : ~r~"..tostring(closest.vehProps.modBrakes).."~s~]"
          lastPlate = closest.vehProps.plate
        end
        DrawText3D(closest.loc.x,closest.loc.y,closest.loc.z + 1.0, drawText)
        DrawText3D(closest.loc.x,closest.loc.y,closest.loc.z + 0.9, drawTextB)
        DrawText3D(closest.loc.x,closest.loc.y,closest.loc.z + 0.8, drawTextC)
        if IsControlJustPressed(0,38) and closestDist < 5.0 and GetGameTimer() - lastTimer > 150 then
          lastTimer = GetGameTimer()
          if not isConfirming then
            if user_owner ~= user_id then
              drawText = "[~r~"..GetDisplayNameFromVehicleModel(closest.vehProps.model).."~s~] Press [~r~E~s~] again to confirm the purchase [~r~$"..closest.price.."~s~]"
            else
              lastPlate = false
              BuyVehicle(closest)
            end
            isConfirming = true
          else
            lastPlate = false
            isConfirming = false
            BuyVehicle(closest)
          end
        end
      end, closest.vehProps)
    else
      lastPlate = false
      isConfirming = false
    end
  end
end)

function AddCar(source,vehId,loc,price,props,id)
  local veh = NetworkGetEntityFromNetworkId(vehId)
  SetEntityAsMissionEntity(veh,true,true)
  SetVehicleDoorsLocked(veh,2)
  SetVehicleDoorsLockedForAllPlayers(veh,true)
  SetEntityInvincible(veh,true)

  table.insert(forSale,{veh = vehId, loc = loc, price = price, vehProps = props, owner = id})
end

function BuyVehicle(closest)
  TSC('MF_VehSales:TryBuy', function(can,msg)
    if can then
      exports['mythic_notify']:DoHudText('inform', msg)
      TSE('MF_VehSales:BuyVeh',closest)
    else
      exports['mythic_notify']:DoHudText('inform', msg)
    end
  end,closest)
end

function SellCar(price)
  if not price or not price[1] then exports['mythic_notify']:DoHudText('error', "Need for an amount"); return; end
  if type(price) == "table" then price = tonumber(price[1]); end
  if not price or type(price) ~= "number" or price <= 0 then exports['mythic_notify']:DoHudText('error', "Stop Kiding"); return; end
  if not IsPedInAnyVehicle(GetPlayerPed(-1),false) then exports['mythic_notify']:DoHudText('error', 'You need be in a vehicle'); return; end
  if not sellAnywhere and GetVecDist(GetEntityCoords(GetPlayerPed(-1)),salesYard) > salesRadius then exports['mythic_notify']:DoHudText('error', 'You must be in the sales yard to do this'); return; end
  local veh = GetVehiclePedIsIn(GetPlayerPed(-1),false)
  local vehProps = PT.Game.GetVehicleProperties(veh)
  TSC('MF_VehSales:TrySell', function(canSell,msg)
    if not canSell then
      exports['mythic_notify']:DoHudText('inform', msg)
    else
      TaskLeaveVehicle(GetPlayerPed(-1),veh,0)
      TaskEveryoneLeaveVehicle(veh)
      local vehId = NetworkGetNetworkIdFromEntity(veh)
      TSE('MF_VehSales:AddSale',vehId,GetEntityCoords(veh),price,vehProps)
    end
  end, vehProps)
end

function RemoveVeh(source,veh)
  local vehi = veh
  print(veh.veh)
  print(vehi.veh)
  local veh = NetworkGetEntityFromNetworkId(veh.veh)
  SetEntityAsMissionEntity(veh,true,true)
  SetVehicleDoorsLocked(veh,0)
  SetVehicleDoorsLockedForAllPlayers(veh,false)
  SetEntityInvincible(veh,false)

  for k,v in pairs(forSale) do
    if v.vehProps.plate == vehi.vehProps.plate then forSale[k] = nil; end
  end
end

RegisterCommand('VenderCarro', function(source,args) SellCar(args); end)
NewEvent(true,AddCar,'MF_VehSales:AddToSale')
NewEvent(true,RemoveVeh,'MF_VehSales:RemoveFromSale')
