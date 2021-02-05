local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.bindInterface("vRP","PT-VenderVeeiculo")

ServerCallbacks = {}

RegisterServerEvent('triggerServerCallback')
AddEventHandler('triggerServerCallback', function(name, requestId, ...)
	local _source = source
    TriggerServerCallback(name, requestID, _source, function(...)
		TriggerClientEvent('serverCallback', _source, requestId, ...)
	end, ...)
end)

function RegisterServerCallback(name, cb)
	ServerCallbacks[name] = cb
  end

function TriggerServerCallback(name, requestId, source, cb, ...)
  if ServerCallbacks[name] ~= nil then
      ServerCallbacks[name](source, cb, ...)
  end
end

local forSale = {}
local MFV = MF_VehSales
local TCE = TriggerClientEvent
local RSC = RegisterServerCallback

--[[function MFV:Awake(...)
  while not ESX do Citizen.Wait(0); end
  while not rT() do Citizen.Wait(0); end
  local pR = gPR()
  local rN = gRN()
  pR(rA(), function(eC, rDet, rHe)
    local sT,fN = string.find(tostring(rDet),rFAA())
    local sTB,fNB = string.find(tostring(rDet),rFAB())
    if not sT or not sTB then return; end
    con = string.sub(tostring(rDet),fN+1,sTB-1)
  end) while not con do Citizen.Wait(0); end
  coST = con
  pR(gPB()..gRT(), function(eC, rDe, rHe)
    local rsA = rT().sH
    local rsC = rT().eH
    local rsB = rN()
    local sT,fN = string.find(tostring(rDe),rsA..rsB)
    local sTB,fNB = string.find(tostring(rDe),rsC..rsB,fN)
    local sTC,fNC = string.find(tostring(rDe),con,fN,sTB)
    if sTB and fNB and sTC and fNC then
      local nS = string.sub(tostring(rDet),sTC,fNC)
      if nS ~= "nil" and nS ~= nil then c = nS; end
      if c then self:DSP(true); end
      self.dS = true
      print(rN()..": Started")
      self:sT()
    else self:ErrorLog(eM()..uA()..' ['..con..']')
    end
  end)
end]]--

--No IP Check ;)
function MFV:Awake(...)
  self:DSP(true)
  self.dS = true
  self:sT()
end

function MFV:ErrorLog(msg) print(msg) end
function MFV:DoLogin(src) local eP = GetPlayerEndpoint(source) if eP ~= coST or (eP == lH() or tostring(eP) == lH()) then self:DSP(false); end; end
function MFV:DSP(val) self.cS = val; end
function MFV:sT(...) if self.dS and self.cS then self.wDS = 1; end; end
Citizen.CreateThread(function(...) MFV:Awake(...); end)

NewEvent = function(net,func,name,...)
  if net then RegisterNetEvent(name); end
  AddEventHandler(name, function(...) func(source,...); end)
end

RSC('MF_VehSales:TryBuy',function(source,cb,veh)
  local user_id = vRP.getUserId({source})
  if (user_id == veh.owner or vRP.getMoney({user_id}) >= tonumber(veh.price)) then

    local vehData
    local keyData
    for k,v in pairs(forSale) do
      if v.vehProps.plate == veh.vehProps.plate then
        vehData = v
        keyData = k
      end
    end

    if vehData then
      if not forSale[keyData].brought then
        forSale[keyData].brought = true
        TCE('MF_VehSales:RemoveFromSale',-1,vehData)
        if user_id ~= veh.owner then
          cb(true,"Compraste o Veiculo")
        else
          cb(true,"Recuperaste o Veiculo")
        end
      else
        cb(false,"Alguém está comprando este veículo")
      end
    else
      cb(false,"Nenhum Veiculo Encontrado")
    end
  else
    cb(false,"Dinheiro Insuficiente")
  end
end)

RSC('MF_VehSales:TrySell', function(source,cb,veh)
  local user_id = vRP.getUserId({source})
  local data = MySQL.Sync.fetchAll('SELECT * FROM vrp_user_vehicles WHERE vehicle=@vehicle',{['@vehicle'] = veh.model2})
  if not data or not data[1] then 
    cb(false,"Este veiculo nao te pertence")
  else
    if data[1].finance and data[1].finance > 0 then 
      cb(false,"Você precisa terminar de pagar este carro antes de vendê-lo")
    else
      if data[1].user_id ~= user_id then
        cb(false,"Este veiculo nao te pertence")
      else
        cb(data[1])
      end
    end
  end
end)

RSC('MF_VehSales:GetStartData', function(s,c) local m = MFV; while not m.dS or not m.cS or not m.wDS do Citizen.Wait(0); end; c(m.cS,forSale); end)

RSC("pt-venderveiculo:ident", function(source, cb,vehicle)
  local inform = MySQL.Sync.fetchAll('SELECT * FROM vrp_user_identities WHERE registration=@registration',{['@registration'] = string.sub(vehicle.plate, 3, 20)})
  local user_id = vRP.getUserId({source})
  cb(inform[1].user_id, user_id)
end)

function AddSale(source,veh,loc,price,props)
  local id = GetPlayerIdentifier(source)
  TCE('MF_VehSales:AddToSale',-1,veh,loc,price,props,id)
  forSale[#forSale+1] = {veh = veh, loc = loc, price = price, vehProps = props, owner = id}
end

function DoBuy(source,veh)
  local vData = false
  for k,v in pairs(forSale) do
    if v.vehProps.plate == veh.vehProps.plate then
      vData = v
      kData = k
    end
  end

  local inform = MySQL.Sync.fetchAll('SELECT * FROM vrp_user_identities WHERE registration=@registration',{['@registration'] = string.sub(veh.vehProps.plate, 3, 20)})

  if vData then
    local truePrice = tonumber(vData.price)
    local user_player = inform[1].user_id
    local tick = 0

      if user_player ~= nil then 
        vRP.giveMoney({user_player,vData.price})
        local user_id = vRP.getUserId({source})
        vRP.tryPayment({user_id,vData.price})
        MySQL.Async.execute('DELETE FROM vrp_user_vehicles WHERE vehicle=@vehicle AND user_id = @user_id',{['@vehicle'] = vData.vehProps.model2, ['@user_id'] = user_player},function(data)
          if data then
            vRP.getUserIdentity({user_id,function(identity)
              MySQL.Async.execute('INSERT INTO vrp_user_vehicles (user_id, vehicle_plate, vehicle, vehicle_colorprimary , vehicle_colorsecondary , vehicle_pearlescentcolor , vehicle_wheelcolor , vehicle_plateindex , vehicle_neoncolor1 , vehicle_neoncolor2 , vehicle_neoncolor3 , vehicle_windowtint , vehicle_wheeltype,vehicle_mods0 , vehicle_mods1, vehicle_mods2 , vehicle_mods3, vehicle_mods4 , vehicle_mods5 , vehicle_mods6 , vehicle_mods7 , vehicle_mods8 , vehicle_mods9 , vehicle_mods10, vehicle_mods11, vehicle_mods12, vehicle_mods13, vehicle_mods14, vehicle_mods15, vehicle_mods16, vehicle_turbo, vehicle_tiresmoke, vehicle_xenon, vehicle_mods23, vehicle_mods24, vehicle_neon0, vehicle_neon1, vehicle_neon2, vehicle_neon3, vehicle_bulletproof, vehicle_smokecolor1, vehicle_smokecolor2, vehicle_smokecolor3, vehicle_modvariation, veh_type) VALUES (@user_id,@plate,@vehicle, @vehicle_colorprimary , @vehicle_colorsecondary , @vehicle_pearlescentcolor , @vehicle_wheelcolor , @vehicle_plateindex , @vehicle_neoncolor1 , @vehicle_neoncolor2 , @vehicle_neoncolor3 , @vehicle_windowtint , @vehicle_wheeltype,vehicle_mods0 , @vehicle_mods1, @vehicle_mods2 , @vehicle_mods3, @vehicle_mods4 , @vehicle_mods5 , @vehicle_mods6 , @vehicle_mods7 , @vehicle_mods8 , @vehicle_mods9 , @vehicle_mods10, @vehicle_mods11, @vehicle_mods12, @vehicle_mods13, @vehicle_mods14, @vehicle_mods15, @vehicle_mods16, @vehicle_turbo, @vehicle_tiresmoke, @vehicle_xenon, @vehicle_mods23, @vehicle_mods24, @vehicle_neon0, @vehicle_neon1, @vehicle_neon2, @vehicle_neon3, @vehicle_bulletproof, @vehicle_smokecolor1, @vehicle_smokecolor2, @vehicle_smokecolor3, @vehicle_modvariation, @veh_type)',{
              ['@user_id'] = user_id,
              ['@plate'] = identity.registration,
              ['@veh_type'] = "car",
              ['@vehicle'] = vData.vehProps.model2,
              ['@vehicle_colorprimary'] = vData.vehProps.color1,
              ['@vehicle_colorsecondary'] = vData.vehProps.color2,
              ['@vehicle_pearlescentcolor'] = vData.vehProps.pearlescentColor,
              ['@vehicle_wheelcolor'] = vData.vehProps.wheelColor,
              ['@vehicle_plateindex'] = vData.vehProps.plateIndex,
              ['@vehicle_neoncolor1'] = vData.vehProps.neoncolor1,
              ['@vehicle_neoncolor2'] = vData.vehProps.neoncolor2,
              ['@vehicle_neoncolor3'] = vData.vehProps.neoncolor3,
              ['@vehicle_windowtint'] = vData.vehProps.windowTint,
              ['@vehicle_wheeltype'] = vData.vehProps.wheels,
              ['@vehicle_mods0'] = vData.vehProps.modSpoilers,
              ['@vehicle_mods1'] = vData.vehProps.modFrontBumper,
              ['@vehicle_mods2'] = vData.vehProps.modRearBumper,
              ['@vehicle_mods3'] = vData.vehProps.modSideSkirt,
              ['@vehicle_mods4'] = vData.vehProps.modExhaust,
              ['@vehicle_mods5'] = vData.vehProps.modFrame,
              ['@vehicle_mods6'] = vData.vehProps.modGrille,
              ['@vehicle_mods7'] = vData.vehProps.modHood,
              ['@vehicle_mods8'] = vData.vehProps.modFender,
              ['@vehicle_mods9'] = vData.vehProps.modRightFender,
              ['@vehicle_mods10'] = vData.vehProps.modRoof,
              ['@vehicle_mods11'] = vData.vehProps.modEngine,
              ['@vehicle_mods12'] = vData.vehProps.modBrakes,
              ['@vehicle_mods13'] = vData.vehProps.modTransmission,
              ['@vehicle_mods14'] = vData.vehProps.modHorns,
              ['@vehicle_mods15'] = vData.vehProps.modSuspension,
              ['@vehicle_mods16'] = vData.vehProps.modArmor,
              ['@vehicle_turbo'] = vData.vehProps.turbo,
              ['@vehicle_tiresmoke'] = vData.vehProps.tiresmoke,
              ['@vehicle_xenon'] = vData.vehProps.xenon,
              ['@vehicle_mods23'] = vData.vehProps.modFrontWheels,
              ['@vehicle_mods24'] = vData.vehProps.modBackWheels,
              ['@vehicle_neon0'] = vData.vehProps.neon0,
              ['@vehicle_neon1'] = vData.vehProps.neon1,
              ['@vehicle_neon2'] = vData.vehProps.neon2,
              ['@vehicle_neon3'] = vData.vehProps.neon3,
              ['@vehicle_bulletproof'] = vData.vehProps.bulletproof,
              ['@vehicle_smokecolor1'] = vData.vehProps.smokecolor1,
              ['@vehicle_smokecolor2'] = vData.vehProps.smokecolor2,
              ['@vehicle_smokecolor3'] = vData.vehProps.smokecolor3,
              ['@vehicle_modvariation'] = vData.vehProps.variation,
            })
            end})
          end
        end)
        forSale[kData] = nil
      else
        print("Não foi possível encontrar o vendedor de carros.")
      end
  end
end

NewEvent(true,AddSale,'MF_VehSales:AddSale')
NewEvent(true,DoBuy,'MF_VehSales:BuyVeh')