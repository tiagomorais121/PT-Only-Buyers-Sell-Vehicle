resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'vRP PT-VenderVeeiculo Converted by PTUltra'
author 'PTUltra#0001'
version '1.0.0'

client_scripts {
  'incl.lua',
  'config.lua',
	'client.lua',
}

server_scripts {	
  '@vrp/lib/utils.lua',
  '@mysql-async/lib/MySQL.lua',
  'incl.lua',
  'config.lua',
	'server.lua',
}