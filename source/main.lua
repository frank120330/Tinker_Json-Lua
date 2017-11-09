local TkTest = require('TkTest')
local TkJson = require('TkJson')

local TestError = function(errorCode, json)
  local result, value = TkJson.parse(json)
  TkTest.expectEqualInt(errorCode, result)
  TkTest.expectEqualLiteral(nil, value)
end

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

local TestString = function(str, json)
  local result, value = TkJson.parse(json)
  TkTest.expectEqualInt(TkJson.errorCode.eOk, result)
  TkTest.expectEqualString(str, value)
end

local TestArray = function(array, json)
  local result, value = TkJson.parse(json)
  TkTest.expectEqualInt(TkJson.errorCode.eOk, result)
  TkTest.expectEqualArray(array, value)
end

local TestParseLiteral = function()
  TestLiteral(nil, 'null')
  TestLiteral(true, 'true')
  TestLiteral(false, 'false')
end

local TestParseIllegalLiteral = function()
  TestError(TkJson.errorCode.eExpectValue, '')
  TestError(TkJson.errorCode.eExpectValue, ' ')

  TestError(TkJson.errorCode.eInvalidValue, 'nul')
  TestError(TkJson.errorCode.eInvalidValue, '?')

  TestError(TkJson.errorCode.eRootNotSingular, 'null x')
end

local TestParseNumber = function()
  TestNumber(0.0, '0')
  TestNumber(0.0, '-0')
  TestNumber(0.0, '-0.0')
  TestNumber(1.0, '1')
  TestNumber(-1.0, '-1')
  TestNumber(1.5, '1.5')
  TestNumber(-1.5, '-1.5')
  TestNumber(3.1416, '3.1416')
  TestNumber(1E10, '1E10')
  TestNumber(1e10, '1e10')
  TestNumber(1E+10, '1E+10')
  TestNumber(1E-10, '1E-10')
  TestNumber(-1E10, '-1E10')
  TestNumber(-1e10, '-1e10')
  TestNumber(-1E+10, '-1E+10')
  TestNumber(-1E-10, '-1E-10')
  TestNumber(1.234E+10, '1.234E+10')
  TestNumber(1.234E-10, '1.234E-10')
  TestNumber(0.0, '1e-10000')

  TestNumber(1.0000000000000002, '1.0000000000000002')
  TestNumber( 4.9406564584124654e-324, '4.9406564584124654e-324')
  TestNumber(-4.9406564584124654e-324, '-4.9406564584124654e-324')
  TestNumber( 2.2250738585072009e-308, '2.2250738585072009e-308')
  TestNumber(-2.2250738585072009e-308, '-2.2250738585072009e-308')
  TestNumber( 2.2250738585072014e-308, '2.2250738585072014e-308')
  TestNumber(-2.2250738585072014e-308, '-2.2250738585072014e-308')
  TestNumber( 1.7976931348623157e+308, '1.7976931348623157e+308')
  TestNumber(-1.7976931348623157e+308, '-1.7976931348623157e+308')
end

local TestParseIllegalNumber = function()
  TestError(TkJson.errorCode.eInvalidValue, '+0')
  TestError(TkJson.errorCode.eInvalidValue, '+1')
  TestError(TkJson.errorCode.eInvalidValue, '.123')
  TestError(TkJson.errorCode.eInvalidValue, '1.')
  TestError(TkJson.errorCode.eInvalidValue, 'INF')
  TestError(TkJson.errorCode.eInvalidValue, 'inf')
  TestError(TkJson.errorCode.eInvalidValue, 'NAN')
  TestError(TkJson.errorCode.eInvalidValue, 'nan')

  TestError(TkJson.errorCode.eNumberTooBig, '1e309')
  TestError(TkJson.errorCode.eNumberTooBig, '-1e309')
  TestError(TkJson.errorCode.eRootNotSingular, '0123')
  TestError(TkJson.errorCode.eRootNotSingular, '0x0')
  TestError(TkJson.errorCode.eRootNotSingular, '0x123')
end

local TestParseString = function()
  TestString('', '\"\"')
  TestString('Hello', '\"Hello\"')
  TestString('Hello\nWorld', '\"Hello\\nWorld\"')
  TestString('\" \\ / \b \f \n \r \t', '\"\\\" \\\\ \\/ \\b \\f \\n \\r \\t\"')
  TestString('Hello\0World', '\"Hello\\u0000World\"')
  TestString('\x24', '\"\\u0024\"')
  TestString('\xC2\xA2', '\"\\u00A2\"')
  TestString('\xE2\x82\xAC', '\"\\u20AC\"')
  TestString('\xF0\x9D\x84\x9E', '\"\\uD834\\uDD1E\"')
  TestString('\xF0\x9D\x84\x9E', '\"\\ud834\\udd1e\"')
end

local TestParseIllegalString = function()
  TestError(TkJson.errorCode.eMissQuotationMark, '\"');
  TestError(TkJson.errorCode.eMissQuotationMark, '\"abc');
  TestError(TkJson.errorCode.eInvalidStringEscape, '\"\\v\"');
  TestError(TkJson.errorCode.eInvalidStringEscape, '\"\\;\"');
  TestError(TkJson.errorCode.eInvalidStringEscape, '\"\\0\"');
  TestError(TkJson.errorCode.eInvalidStringEscape, '\"\\x12\"');
  TestError(TkJson.errorCode.eInvalidStringChar, '\"\x01\"');
  TestError(TkJson.errorCode.eInvalidStringChar, '\"\x1F\"');
end

local function TestParseArray()
  TestArray({ nil, false, true, 123, 'abc' }, '[ null , false , true , 123 , \"abc\" ]')
  TestArray({}, '[ ]')
  TestArray({ {}, { 0 }, { 0, 1 }, { 0, 1, 2} }, '[ [ ] , [ 0 ] , [ 0 , 1 ] , [ 0 , 1 , 2 ] ]')
end

local TestParse = function()
  TestParseLiteral()
  TestParseIllegalLiteral()
  TestParseNumber()
  TestParseIllegalNumber()
  TestParseString()
  TestParseIllegalString()

  print('> All Tests Passed!')
end

TestParse()
