--[[  
Date: 
  2017.12.01
Author: 
  Ly.TinKeR
Description:
  This module is a benchmark driver, using three JSON texts to test the speed
  of a certain JSON parser. The parser to be tested must have a function 
  named `decode` which is the function that will be used for parsing JSON.
--]]

local TkBench = {}

TkBench.parserArray = {}

TkBench.addParser = function(parser)
  local newParser = {}
  newParser.jsonParser = parser
  newParser.elapsedTime = 0.0
  table.insert(TkBench.parserArray, newParser)
end

TkBench.testAll = function()
  
end

return TkBench

