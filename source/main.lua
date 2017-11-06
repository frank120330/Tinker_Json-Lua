local TkTest = require('TkTest')
local TkJson = require('TkJson')

local TestParseNull = function()
  local result, value = TkJson.parse('null')
  TkTest.expectEqualInt(TkJson.errorCode.eOk, result)
  TkTest.expectEqualNil(value)
end

local TestParse = function()
  TestParseNull()
  print('> All Tests Passed!')
end

TestParse()
