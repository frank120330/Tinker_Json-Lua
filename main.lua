local TkJson = require('source/TkJson')
local TkParserTester = require('source/TkParserTester')

local TestLiteral = function()
  TkParserTester.testParseLiteral(nil, 'null')
  TkParserTester.testParseLiteral(true, 'true')
  TkParserTester.testParseLiteral(false, 'false')
end

local TestIllegalLiteral = function()
  TkParserTester.testParseError(TkJson.errorCode.eExpectValue, '')
  TkParserTester.testParseError(TkJson.errorCode.eExpectValue, ' ')

  TkParserTester.testParseError(TkJson.errorCode.eInvalidValue, 'nul')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidValue, '?')

  TkParserTester.testParseError(TkJson.errorCode.eRootNotSingular, 'null x')
end

local TestNumber = function()
  TkParserTester.testParseNumber(0.0, '0')
  TkParserTester.testParseNumber(0.0, '-0')
  TkParserTester.testParseNumber(0.0, '-0.0')
  TkParserTester.testParseNumber(1.0, '1')
  TkParserTester.testParseNumber(-1.0, '-1')
  TkParserTester.testParseNumber(1.5, '1.5')
  TkParserTester.testParseNumber(-1.5, '-1.5')
  TkParserTester.testParseNumber(3.1416, '3.1416')
  TkParserTester.testParseNumber(1E10, '1E10')
  TkParserTester.testParseNumber(1e10, '1e10')
  TkParserTester.testParseNumber(1E+10, '1E+10')
  TkParserTester.testParseNumber(1E-10, '1E-10')
  TkParserTester.testParseNumber(-1E10, '-1E10')
  TkParserTester.testParseNumber(-1e10, '-1e10')
  TkParserTester.testParseNumber(-1E+10, '-1E+10')
  TkParserTester.testParseNumber(-1E-10, '-1E-10')
  TkParserTester.testParseNumber(1.234E+10, '1.234E+10')
  TkParserTester.testParseNumber(1.234E-10, '1.234E-10')
  TkParserTester.testParseNumber(0.0, '1e-10000')

  TkParserTester.testParseNumber(1.0000000000000002, '1.0000000000000002')
  TkParserTester.testParseNumber( 4.9406564584124654e-324, '4.9406564584124654e-324')
  TkParserTester.testParseNumber(-4.9406564584124654e-324, '-4.9406564584124654e-324')
  TkParserTester.testParseNumber( 2.2250738585072009e-308, '2.2250738585072009e-308')
  TkParserTester.testParseNumber(-2.2250738585072009e-308, '-2.2250738585072009e-308')
  TkParserTester.testParseNumber( 2.2250738585072014e-308, '2.2250738585072014e-308')
  TkParserTester.testParseNumber(-2.2250738585072014e-308, '-2.2250738585072014e-308')
  TkParserTester.testParseNumber( 1.7976931348623157e+308, '1.7976931348623157e+308')
  TkParserTester.testParseNumber(-1.7976931348623157e+308, '-1.7976931348623157e+308')
end

local TestIllegalNumber = function()
  TkParserTester.testParseError(TkJson.errorCode.eInvalidValue, '+0')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidValue, '+1')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidValue, '.123')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidValue, '1.')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidValue, 'INF')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidValue, 'inf')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidValue, 'NAN')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidValue, 'nan')

  TkParserTester.testParseError(TkJson.errorCode.eNumberTooBig, '1e309')
  TkParserTester.testParseError(TkJson.errorCode.eNumberTooBig, '-1e309')
  TkParserTester.testParseError(TkJson.errorCode.eRootNotSingular, '0123')
  TkParserTester.testParseError(TkJson.errorCode.eRootNotSingular, '0x0')
  TkParserTester.testParseError(TkJson.errorCode.eRootNotSingular, '0x123')
end

local TestString = function()
  TkParserTester.testParseString('', '\"\"')
  TkParserTester.testParseString('Hello', '\"Hello\"')
  TkParserTester.testParseString('Hello\nWorld', '\"Hello\\nWorld\"')
  TkParserTester.testParseString('\" \\ / \b \f \n \r \t', '\"\\\" \\\\ \\/ \\b \\f \\n \\r \\t\"')
  TkParserTester.testParseString('Hello\0World', '\"Hello\\u0000World\"')
  TkParserTester.testParseString('\x24', '\"\\u0024\"')
  TkParserTester.testParseString('\xC2\xA2', '\"\\u00A2\"')
  TkParserTester.testParseString('\xE2\x82\xAC', '\"\\u20AC\"')
  TkParserTester.testParseString('\xF0\x9D\x84\x9E', '\"\\uD834\\uDD1E\"')
  TkParserTester.testParseString('\xF0\x9D\x84\x9E', '\"\\ud834\\udd1e\"')
end

local TestIllegalString = function()
  TkParserTester.testParseError(TkJson.errorCode.eMissQuotationMark, '\"')
  TkParserTester.testParseError(TkJson.errorCode.eMissQuotationMark, '\"abc')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidStringEscape, '\"\\v\"')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidStringEscape, '\"\\;\"')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidStringEscape, '\"\\0\"')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidStringEscape, '\"\\x12\"')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidStringChar, '\"\x01\"')
  TkParserTester.testParseError(TkJson.errorCode.eInvalidStringChar, '\"\x1F\"')
end

local TestArray = function()
  TkParserTester.testParseArray(
    { nil, false, true, 123, 'abc', __length = 5 }, 
    '[ null , false , true , 123 , \"abc\" ]'
  )
  TkParserTester.testParseArray({ __length = 0 }, '[ ]')
  TkParserTester.testParseArray(
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
  TkParserTester.testParseError(TkJson.errorCode.eMissCommaOrSquareBracket, '[1')
  TkParserTester.testParseError(TkJson.errorCode.eMissCommaOrSquareBracket, '[1}')
  TkParserTester.testParseError(TkJson.errorCode.eMissCommaOrSquareBracket, '[1 2')
  TkParserTester.testParseError(TkJson.errorCode.eMissCommaOrSquareBracket, '[[]')
end

local TestObject = function()
  TkParserTester.testParseObject({}, '{}')
  TkParserTester.testParseObject(
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
  TkParserTester.testParseError(TkJson.errorCode.eMissKey, '{:1,')
  TkParserTester.testParseError(TkJson.errorCode.eMissKey, '{1:1,')
  TkParserTester.testParseError(TkJson.errorCode.eMissKey, '{true:1,')
  TkParserTester.testParseError(TkJson.errorCode.eMissKey, '{false:1,')
  TkParserTester.testParseError(TkJson.errorCode.eMissKey, '{null:1,')
  TkParserTester.testParseError(TkJson.errorCode.eMissKey, '{[]:1,')
  TkParserTester.testParseError(TkJson.errorCode.eMissKey, '{{}:1,')
  TkParserTester.testParseError(TkJson.errorCode.eMissKey, '{\"a\":1,')

  TkParserTester.testParseError(TkJson.errorCode.eMissColon, '{\"a\"}')
  TkParserTester.testParseError(TkJson.errorCode.eMissColon, '{\"a\",\"b\"}')

  TkParserTester.testParseError(TkJson.errorCode.eMissCommaOrCurlyBracket, '{\"a\":1')
  TkParserTester.testParseError(TkJson.errorCode.eMissCommaOrCurlyBracket, '{\"a\":1]')
  TkParserTester.testParseError(TkJson.errorCode.eMissCommaOrCurlyBracket, '{\"a\":1 \"b\"')
  TkParserTester.testParseError(TkJson.errorCode.eMissCommaOrCurlyBracket, '{\"a\":{}')
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
  TkParserTester.testParseFile('test/simple.json')
  TkParserTester.testParseFile('test/twitter.json')
  TkParserTester.testParseFile('test/canada.json')
  TkParserTester.testParseFile('test/citm_catalog.json')
end

TestParser()
TestFile()
