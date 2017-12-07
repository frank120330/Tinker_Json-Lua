local TkJson = require('source/TkJson')
local TkTest = require('source/TkTest')

local TkDriver = {}

TkDriver.testParseError = function(errorCode, errorRow, errorCol, json)
  local status, errorMsg = pcall(TkJson.parse, json)
  local expectError = string.format(
    '# Error: Line %d Column %d - %s', 
    errorRow, errorCol, errorCode
  )
  TkTest.expectEqualLiteral(false, status)
  TkTest.expectEqualString(expectError, errorMsg)
end

TkDriver.testParseNull = function(json)
  local value = TkJson.parse(json)
  TkTest.expectEqualNull(TkJson.null, value)
end

TkDriver.testParseLiteral = function(literal, json)
  local value = TkJson.parse(json)
  TkTest.expectEqualLiteral(literal, value)
end

TkDriver.testParseNumber = function(number, json)
  local value = TkJson.parse(json)
  TkTest.expectEqualNumber(number, value)
end

TkDriver.testParseString = function(str, json)
  local value = TkJson.parse(json)
  TkTest.expectEqualString(str, value)
end

TkDriver.testParseArray = function(array, json)
  local value = TkJson.parse(json)
  TkTest.expectEqualArray(array, value)
end

TkDriver.testParseObject = function(object, json)
  local value = TkJson.parse(json)
  TkTest.expectEqualObject(object, value)
end

TkDriver.testParseFile = function(filename)
  local jsonFile = assert(io.open(filename, 'r'))
  local jsonString = jsonFile:read('a')
  local startClock = os.clock()
  local value = TkJson.parse(jsonString)
  local stopClock = os.clock()
  print(string.format("> Pressure Test - Filename: %s, Elapsed Time: %fs", filename, stopClock - startClock))
end

return TkDriver