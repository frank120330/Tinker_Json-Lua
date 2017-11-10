local TkJson = require('source/TkJson')
local TkTest = require('source/TkTest')

local TkParserTester = {}

TkParserTester.testParseError = function(errorCode, json)
  local result, value = TkJson.parse(json)
  TkTest.expectEqualInt(errorCode, result)
  TkTest.expectEqualLiteral(nil, value)
end

TkParserTester.testParseLiteral = function(literal, json)
  local result, value = TkJson.parse(json)
  TkTest.expectEqualInt(TkJson.errorCode.eOk, result)
  TkTest.expectEqualLiteral(literal, value)
end

TkParserTester.testParseNumber = function(number, json)
  local result, value = TkJson.parse(json)
  TkTest.expectEqualInt(TkJson.errorCode.eOk, result)
  TkTest.expectEqualNumber(number, value)
end

TkParserTester.testParseString = function(str, json)
  local result, value = TkJson.parse(json)
  TkTest.expectEqualInt(TkJson.errorCode.eOk, result)
  TkTest.expectEqualString(str, value)
end

TkParserTester.testParseArray = function(array, json)
  local result, value = TkJson.parse(json)
  TkTest.expectEqualInt(TkJson.errorCode.eOk, result)
  TkTest.expectEqualArray(array, value)
end

TkParserTester.testParseObject = function(object, json)
  local result, value = TkJson.parse(json)
  TkTest.expectEqualInt(TkJson.errorCode.eOk, result)
  TkTest.expectEqualObject(object, value)
end

TkParserTester.testParseFile = function(filename)
  local jsonFile = assert(io.open(filename, 'r'))
  local jsonString = jsonFile:read('a')
  local startClock = os.clock()
  local result, value = TkJson.parse(jsonString)
  local stopClock = os.clock()
  TkTest.expectEqualInt(TkJson.errorCode.eOk, result)
  print(string.format("> Pressure Test - Filename: %s, Elapsed Time: %fs", filename, stopClock - startClock))
end

return TkParserTester