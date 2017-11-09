local TkTest = require('TkTest')
local TkJson = require('TkJson')

local TestLiteral = function(literal, json)
  local result, value = TkJson.parse(json)
  TkTest.expectEqualInt(TkJson.errorCode.eOk, result)
  TkTest.expectEqualLiteral(literal, value)
end

local TestNumber = function(number, json)
  local result, value = TkJson.parse(json)
  TkTest.expectEqualInt(TkJson.errorCode.eOk, result)
  TkTest.expectEqualNumber(number, value)
end

local TestParseLiteral = function()
  TestLiteral(nil, 'null')
  TestLiteral(true, 'true')
  TestLiteral(false, 'false')
end

local TestParseNumber = function()
  TestNumber(0.0, '0');
  TestNumber(0.0, '-0');
  TestNumber(0.0, '-0.0');
  TestNumber(1.0, '1');
  TestNumber(-1.0, '-1');
  TestNumber(1.5, '1.5');
  TestNumber(-1.5, '-1.5');
  TestNumber(3.1416, '3.1416');
  TestNumber(1E10, '1E10');
  TestNumber(1e10, '1e10');
  TestNumber(1E+10, '1E+10');
  TestNumber(1E-10, '1E-10');
  TestNumber(-1E10, '-1E10');
  TestNumber(-1e10, '-1e10');
  TestNumber(-1E+10, '-1E+10');
  TestNumber(-1E-10, '-1E-10');
  TestNumber(1.234E+10, '1.234E+10');
  TestNumber(1.234E-10, '1.234E-10');
  TestNumber(0.0, '1e-10000');

  TestNumber(1.0000000000000002, '1.0000000000000002');
  TestNumber( 4.9406564584124654e-324, '4.9406564584124654e-324');
  TestNumber(-4.9406564584124654e-324, '-4.9406564584124654e-324');
  TestNumber( 2.2250738585072009e-308, '2.2250738585072009e-308');
  TestNumber(-2.2250738585072009e-308, '-2.2250738585072009e-308');
  TestNumber( 2.2250738585072014e-308, '2.2250738585072014e-308');
  TestNumber(-2.2250738585072014e-308, '-2.2250738585072014e-308');
  TestNumber( 1.7976931348623157e+308, '1.7976931348623157e+308');
  TestNumber(-1.7976931348623157e+308, '-1.7976931348623157e+308');
end

local TestParse = function()
  TestParseLiteral()
  TestParseNumber()
  print('> All Tests Passed!')
end

TestParse()
