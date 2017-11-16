local TkJson = require('source/TkJson')
local TkDriver = require('source/TkDriver')

local TestLiteral = function()
  TkDriver.testParseLiteral(nil, 'null')
  TkDriver.testParseLiteral(true, 'true')
  TkDriver.testParseLiteral(false, 'false')
end

local TestIllegalLiteral = function()
  TkDriver.testParseError(TkJson.errorCode.eExpectValue, 1, 1, '')
  TkDriver.testParseError(TkJson.errorCode.eExpectValue, 1, 2, ' ')

  TkDriver.testParseError(TkJson.errorCode.eInvalidValue, 1, 4, 'nul')
  TkDriver.testParseError(TkJson.errorCode.eInvalidValue, 1, 1, '?')

  TkDriver.testParseError(TkJson.errorCode.eRootNotSingular, 1, 6, 'null x')
end

local TestNumber = function()
  TkDriver.testParseNumber(0.0, '0')
  TkDriver.testParseNumber(0.0, '-0')
  TkDriver.testParseNumber(0.0, '-0.0')
  TkDriver.testParseNumber(1.0, '1')
  TkDriver.testParseNumber(-1.0, '-1')
  TkDriver.testParseNumber(1.5, '1.5')
  TkDriver.testParseNumber(-1.5, '-1.5')
  TkDriver.testParseNumber(3.1416, '3.1416')
  TkDriver.testParseNumber(1E10, '1E10')
  TkDriver.testParseNumber(1e10, '1e10')
  TkDriver.testParseNumber(1E+10, '1E+10')
  TkDriver.testParseNumber(1E-10, '1E-10')
  TkDriver.testParseNumber(-1E10, '-1E10')
  TkDriver.testParseNumber(-1e10, '-1e10')
  TkDriver.testParseNumber(-1E+10, '-1E+10')
  TkDriver.testParseNumber(-1E-10, '-1E-10')
  TkDriver.testParseNumber(1.234E+10, '1.234E+10')
  TkDriver.testParseNumber(1.234E-10, '1.234E-10')
  TkDriver.testParseNumber(0.0, '1e-10000')

  TkDriver.testParseNumber(1.0000000000000002, '1.0000000000000002')
  TkDriver.testParseNumber( 4.9406564584124654e-324, '4.9406564584124654e-324')
  TkDriver.testParseNumber(-4.9406564584124654e-324, '-4.9406564584124654e-324')
  TkDriver.testParseNumber( 2.2250738585072009e-308, '2.2250738585072009e-308')
  TkDriver.testParseNumber(-2.2250738585072009e-308, '-2.2250738585072009e-308')
  TkDriver.testParseNumber( 2.2250738585072014e-308, '2.2250738585072014e-308')
  TkDriver.testParseNumber(-2.2250738585072014e-308, '-2.2250738585072014e-308')
  TkDriver.testParseNumber( 1.7976931348623157e+308, '1.7976931348623157e+308')
  TkDriver.testParseNumber(-1.7976931348623157e+308, '-1.7976931348623157e+308')
end

local TestIllegalNumber = function()
  TkDriver.testParseError(TkJson.errorCode.eInvalidValue, 1, 1, '+0')
  TkDriver.testParseError(TkJson.errorCode.eInvalidValue, 1, 1, '+1')
  TkDriver.testParseError(TkJson.errorCode.eInvalidValue, 1, 1, '.123')
  -- TkDriver.testParseError(TkJson.errorCode.eInvalidValue, '1.')
  TkDriver.testParseError(TkJson.errorCode.eInvalidValue, 1, 1, 'INF')
  TkDriver.testParseError(TkJson.errorCode.eInvalidValue, 1, 1, 'inf')
  TkDriver.testParseError(TkJson.errorCode.eInvalidValue, 1, 1, 'NAN')
  TkDriver.testParseError(TkJson.errorCode.eInvalidValue, 1, 2, 'nan')

  TkDriver.testParseError(TkJson.errorCode.eNumberTooBig, 1, 6, '1e309')
  TkDriver.testParseError(TkJson.errorCode.eNumberTooBig, 1, 7, '-1e309')
  -- TkDriver.testParseError(TkJson.errorCode.eRootNotSingular, '0123')
  TkDriver.testParseError(TkJson.errorCode.eRootNotSingular, 1, 2, '0x0')
  TkDriver.testParseError(TkJson.errorCode.eRootNotSingular, 1, 2, '0x123')
end

local TestString = function()
  TkDriver.testParseString('', '\"\"')
  TkDriver.testParseString('Hello', '\"Hello\"')
  TkDriver.testParseString('Hello\nWorld', '\"Hello\\nWorld\"')
  TkDriver.testParseString('\" \\ / \b \f \n \r \t', '\"\\\" \\\\ \\/ \\b \\f \\n \\r \\t\"')
  TkDriver.testParseString('Hello\0World', '\"Hello\\u0000World\"')
  TkDriver.testParseString('\x24', '\"\\u0024\"')
  TkDriver.testParseString('\xC2\xA2', '\"\\u00A2\"')
  TkDriver.testParseString('\xE2\x82\xAC', '\"\\u20AC\"')
  TkDriver.testParseString('\xF0\x9D\x84\x9E', '\"\\uD834\\uDD1E\"')
  TkDriver.testParseString('\xF0\x9D\x84\x9E', '\"\\ud834\\udd1e\"')
end

local TestIllegalString = function()
  TkDriver.testParseError(TkJson.errorCode.eMissQuotationMark, 1, 2, '\"')
  TkDriver.testParseError(TkJson.errorCode.eMissQuotationMark, 1, 5, '\"abc')
  TkDriver.testParseError(TkJson.errorCode.eInvalidStringEscape, 1, 3, '\"\\v\"')
  TkDriver.testParseError(TkJson.errorCode.eInvalidStringEscape, 1, 3, '\"\\;\"')
  TkDriver.testParseError(TkJson.errorCode.eInvalidStringEscape, 1, 3, '\"\\0\"')
  TkDriver.testParseError(TkJson.errorCode.eInvalidStringEscape, 1, 3, '\"\\x12\"')
  TkDriver.testParseError(TkJson.errorCode.eInvalidStringChar, 1, 3, '\"\x01\"')
  TkDriver.testParseError(TkJson.errorCode.eInvalidStringChar, 1, 3, '\"\x1F\"')
end

local TestArray = function()
  TkDriver.testParseArray(
    { nil, false, true, 123, 'abc', __length = 5 }, 
    '[ null , false , true , 123 , \"abc\" ]'
  )
  TkDriver.testParseArray({ __length = 0 }, '[ ]')
  TkDriver.testParseArray(
    { 
      { __length = 0 }, 
      { 0, __length = 1 }, 
      { 0, 1, __length = 2 }, 
      { 0, 1, 2, __length = 3 }, __length = 4 
    }, 
    '[ [ ] , [ 0 ] , [ 0 , 1 ] , [ 0 , 1 , 2 ] ]'
  )
end

local TestIllegalArray = function()
  TkDriver.testParseError(TkJson.errorCode.eMissCommaOrSquareBracket, 1, 3, '[1')
  TkDriver.testParseError(TkJson.errorCode.eMissCommaOrSquareBracket, 1, 3, '[1}')
  TkDriver.testParseError(TkJson.errorCode.eMissCommaOrSquareBracket, 1, 4, '[1 2')
  TkDriver.testParseError(TkJson.errorCode.eMissCommaOrSquareBracket, 1, 4, '[[]')
end

local TestObject = function()
  TkDriver.testParseObject({}, '{}')
  TkDriver.testParseObject(
    {
      ['n'] = nil,
      ['f'] = false,
      ['t'] = true,
      ['i'] = 123,
      ['s'] = 'abc',
      ['a'] = { 1, 2, 3, __length = 3 },
      ['o'] = { ['1'] = 1, ['2'] = 2, ['3'] = 3 }
    },
    [===[
      {
        "n": null,
        "f": false,
        "t": true,
        "i": 123,
        "s": "abc",
        "a": [ 1, 2, 3 ],
        "o": { "1": 1, "2": 2, "3": 3 }
      }
    ]===]
  )
end

local TestIllegalObject = function()
  TkDriver.testParseError(TkJson.errorCode.eMissKey, 1, 2, '{:1,')
  TkDriver.testParseError(TkJson.errorCode.eMissKey, 1, 2, '{1:1,')
  TkDriver.testParseError(TkJson.errorCode.eMissKey, 1, 2, '{true:1,')
  TkDriver.testParseError(TkJson.errorCode.eMissKey, 1, 2, '{false:1,')
  TkDriver.testParseError(TkJson.errorCode.eMissKey, 1, 2, '{null:1,')
  TkDriver.testParseError(TkJson.errorCode.eMissKey, 1, 2, '{[]:1,')
  TkDriver.testParseError(TkJson.errorCode.eMissKey, 1, 2, '{{}:1,')
  TkDriver.testParseError(TkJson.errorCode.eMissKey, 1, 8, '{\"a\":1,')

  TkDriver.testParseError(TkJson.errorCode.eMissColon, 1, 5, '{\"a\"}')
  TkDriver.testParseError(TkJson.errorCode.eMissColon, 1, 5, '{\"a\",\"b\"}')

  TkDriver.testParseError(TkJson.errorCode.eMissCommaOrCurlyBracket, 1, 7, '{\"a\":1')
  TkDriver.testParseError(TkJson.errorCode.eMissCommaOrCurlyBracket, 1, 7, '{\"a\":1]')
  TkDriver.testParseError(TkJson.errorCode.eMissCommaOrCurlyBracket, 1, 8, '{\"a\":1 \"b\"')
  TkDriver.testParseError(TkJson.errorCode.eMissCommaOrCurlyBracket, 1, 8, '{\"a\":{}')
end

local TestParser = function()
  TestLiteral()
  TestIllegalLiteral()
  TestNumber()
  TestIllegalNumber()
  TestString()
  TestIllegalString()
  TestArray()
  TestIllegalArray()
  TestObject()
  TestIllegalObject()

  print('> All Tests Passed!')
end

local TestFile = function()
  TkDriver.testParseFile('test/simple.json')
  TkDriver.testParseFile('test/twitter.json')
  TkDriver.testParseFile('test/canada.json')
  TkDriver.testParseFile('test/citm_catalog.json')
end

TestParser()
TestFile()
