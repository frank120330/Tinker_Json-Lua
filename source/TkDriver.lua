local TkJson = require('source/TkJson')
local TkTest = require('source/TkTest')

local TkDriver = {}

TkDriver.testDecodeError = function(errorCode, errorRow, errorCol, json)
  local status, errorMsg = pcall(TkJson.decode, json)
  local expectError = string.format(
    '# Error: Line %d Column %d - %s', 
    errorRow, errorCol, errorCode
  )
  TkTest.expectEqualLiteral(false, status)
  TkTest.expectEqualString(expectError, errorMsg)
end

TkDriver.testDecodeNull = function(json)
  local value = TkJson.decode(json)
  TkTest.expectEqualNull(TkJson.null, value)
end

TkDriver.testDecodeLiteral = function(literal, json)
  local value = TkJson.decode(json)
  TkTest.expectEqualLiteral(literal, value)
end

TkDriver.testDecodeNumber = function(number, json)
  local value = TkJson.decode(json)
  TkTest.expectEqualNumber(number, value)
end

TkDriver.testDecodeString = function(str, json)
  local value = TkJson.decode(json)
  TkTest.expectEqualString(str, value)
end

TkDriver.testDecodeArray = function(array, json)
  local value = TkJson.decode(json)
  TkTest.expectEqualArray(array, value)
end

TkDriver.testDecodeObject = function(object, json)
  local value = TkJson.decode(json)
  TkTest.expectEqualObject(object, value)
end

TkDriver.testRoundTrip = function(json)
  local value = TkJson.decode(json)
  local text = TkJson.encode(value)
  TkTest.expectEqualString(json, text)
end

return TkDriver