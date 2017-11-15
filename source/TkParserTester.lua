local TkJson = require('source/TkJson')
local TkTest = require('source/TkTest')
local ProFi = require('ProFi')

local TkParserTester = {}

TkParserTester.testParseError = function(errorCode, errorRow, errorCol, json)
  local status, errorMsg = pcall(TkJson.parse, json)
  local expectError = string.format(
    '# Error: Line %d Column %d - %s', errorRow, errorCol, errorCode
  )
  TkTest.expectEqualLiteral(false, status)
  TkTest.expectEqualString(expectError, errorMsg)
end

TkParserTester.testParseLiteral = function(literal, json)
  local value = TkJson.parse(json)
  TkTest.expectEqualLiteral(literal, value)
end

TkParserTester.testParseNumber = function(number, json)
  local value = TkJson.parse(json)
  TkTest.expectEqualNumber(number, value)
end

TkParserTester.testParseString = function(str, json)
  local value = TkJson.parse(json)
  TkTest.expectEqualString(str, value)
end

TkParserTester.testParseArray = function(array, json)
  local value = TkJson.parse(json)
  TkTest.expectEqualArray(array, value)
end

TkParserTester.testParseObject = function(object, json)
  local value = TkJson.parse(json)
  TkTest.expectEqualObject(object, value)
end

TkParserTester.testParseFile = function(filename)
  local jsonFile = assert(io.open(filename, 'r'))
  local jsonString = jsonFile:read('a')
  local startClock = os.clock()
  --ProFi:start()
  local value = TkJson.parse(jsonString)
  --ProFi:stop()
  --ProFi:writeReport(filename .. '-report.txt')
  local stopClock = os.clock()
  print(string.format("> Pressure Test - Filename: %s, Elapsed Time: %fs", filename, stopClock - startClock))
end

return TkParserTester