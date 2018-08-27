local ProFi = require('ProFi')
local TkJson = require('source/TkJson')

local Profiler = function(filename)
  local jsonFile = assert(io.open(filename, 'r')) 
  local jsonString = jsonFile:read('a') 
  local value = TkJson.decode(jsonString) 
  ProFi:start() 
  local text = TkJson.encode(value)
  ProFi:stop()
  ProFi:writeReport(filename .. '-report.txt') 
end

Profiler('test/twitter.json')