local TkJson = require('source/TkJson')
local TkDriver = require('source/TkDriver')

local TestDecodeLiteral = function()
  TkDriver.testDecodeNull('null')
  TkDriver.testDecodeLiteral(true, 'true')
  TkDriver.testDecodeLiteral(false, 'false')
end

local TestDecodeIllegalLiteral = function()
  TkDriver.testDecodeError(TkJson.errorCode.eExpectValue, 1, 1, '')
  TkDriver.testDecodeError(TkJson.errorCode.eExpectValue, 1, 2, ' ')

  TkDriver.testDecodeError(TkJson.errorCode.eInvalidValue, 1, 4, 'nul')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidValue, 1, 1, '?')

  TkDriver.testDecodeError(TkJson.errorCode.eRootNotSingular, 1, 6, 'null x')
end

local TestDecodeNumber = function()
  TkDriver.testDecodeNumber(0.0, '0')
  TkDriver.testDecodeNumber(0.0, '-0')
  TkDriver.testDecodeNumber(0.0, '-0.0')
  TkDriver.testDecodeNumber(1.0, '1')
  TkDriver.testDecodeNumber(-1.0, '-1')
  TkDriver.testDecodeNumber(1.5, '1.5')
  TkDriver.testDecodeNumber(-1.5, '-1.5')
  TkDriver.testDecodeNumber(3.1416, '3.1416')
  TkDriver.testDecodeNumber(1E10, '1E10')
  TkDriver.testDecodeNumber(1e10, '1e10')
  TkDriver.testDecodeNumber(1E+10, '1E+10')
  TkDriver.testDecodeNumber(1E-10, '1E-10')
  TkDriver.testDecodeNumber(-1E10, '-1E10')
  TkDriver.testDecodeNumber(-1e10, '-1e10')
  TkDriver.testDecodeNumber(-1E+10, '-1E+10')
  TkDriver.testDecodeNumber(-1E-10, '-1E-10')
  TkDriver.testDecodeNumber(1.234E+10, '1.234E+10')
  TkDriver.testDecodeNumber(1.234E-10, '1.234E-10')
  TkDriver.testDecodeNumber(0.0, '1e-10000')

  TkDriver.testDecodeNumber(1.0000000000000002, '1.0000000000000002')
  TkDriver.testDecodeNumber( 4.9406564584124654e-324, '4.9406564584124654e-324')
  TkDriver.testDecodeNumber(-4.9406564584124654e-324, '-4.9406564584124654e-324')
  TkDriver.testDecodeNumber( 2.2250738585072009e-308, '2.2250738585072009e-308')
  TkDriver.testDecodeNumber(-2.2250738585072009e-308, '-2.2250738585072009e-308')
  TkDriver.testDecodeNumber( 2.2250738585072014e-308, '2.2250738585072014e-308')
  TkDriver.testDecodeNumber(-2.2250738585072014e-308, '-2.2250738585072014e-308')
  TkDriver.testDecodeNumber( 1.7976931348623157e+308, '1.7976931348623157e+308')
  TkDriver.testDecodeNumber(-1.7976931348623157e+308, '-1.7976931348623157e+308')
end

local TestDecodeIllegalNumber = function()
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidValue, 1, 1, '+0')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidValue, 1, 1, '+1')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidValue, 1, 1, '.123')
  -- TkDriver.testDecodeError(TkJson.errorCode.eInvalidValue, '1.')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidValue, 1, 1, 'INF')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidValue, 1, 1, 'inf')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidValue, 1, 1, 'NAN')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidValue, 1, 2, 'nan')

  TkDriver.testDecodeError(TkJson.errorCode.eNumberTooBig, 1, 6, '1e309')
  TkDriver.testDecodeError(TkJson.errorCode.eNumberTooBig, 1, 7, '-1e309')
  -- TkDriver.testDecodeError(TkJson.errorCode.eRootNotSingular, '0123')
  TkDriver.testDecodeError(TkJson.errorCode.eRootNotSingular, 1, 2, '0x0')
  TkDriver.testDecodeError(TkJson.errorCode.eRootNotSingular, 1, 2, '0x123')
end

local TestDecodeString = function()
  TkDriver.testDecodeString('', '\"\"')
  TkDriver.testDecodeString('Hello', '\"Hello\"')
  TkDriver.testDecodeString('Hello\nWorld', '\"Hello\\nWorld\"')
  TkDriver.testDecodeString('\" \\ / \b \f \n \r \t', '\"\\\" \\\\ \\/ \\b \\f \\n \\r \\t\"')
  TkDriver.testDecodeString('Hello\0World', '\"Hello\\u0000World\"')
  TkDriver.testDecodeString('\x24', '\"\\u0024\"')
  TkDriver.testDecodeString('\xC2\xA2', '\"\\u00A2\"')
  TkDriver.testDecodeString('\xE2\x82\xAC', '\"\\u20AC\"')
  TkDriver.testDecodeString('\xF0\x9D\x84\x9E', '\"\\uD834\\uDD1E\"')
  TkDriver.testDecodeString('\xF0\x9D\x84\x9E', '\"\\ud834\\udd1e\"')
end

local TestDecodeIllegalString = function()
  TkDriver.testDecodeError(TkJson.errorCode.eMissQuotationMark, 1, 2, '\"')
  TkDriver.testDecodeError(TkJson.errorCode.eMissQuotationMark, 1, 5, '\"abc')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidStringEscape, 1, 3, '\"\\v\"')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidStringEscape, 1, 3, '\"\\;\"')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidStringEscape, 1, 3, '\"\\0\"')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidStringEscape, 1, 3, '\"\\x12\"')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidStringChar, 1, 3, '\"\x01\"')
  TkDriver.testDecodeError(TkJson.errorCode.eInvalidStringChar, 1, 3, '\"\x1F\"')
end

local TestDecodeArray = function()
  TkDriver.testDecodeArray(
    { TkJson.null, false, true, 123, 'abc', __length = 5 }, 
    '[ null , false , true , 123 , \"abc\" ]'
  )
  TkDriver.testDecodeArray({ __length = 0 }, '[ ]')
  TkDriver.testDecodeArray(
    { 
      { __length = 0 }, 
      { 0, __length = 1 }, 
      { 0, 1, __length = 2 }, 
      { 0, 1, 2, __length = 3 }, __length = 4 
    }, 
    '[ [ ] , [ 0 ] , [ 0 , 1 ] , [ 0 , 1 , 2 ] ]'
  )
end

local TestDecodeIllegalArray = function()
  TkDriver.testDecodeError(TkJson.errorCode.eMissCommaOrSquareBracket, 1, 3, '[1')
  TkDriver.testDecodeError(TkJson.errorCode.eMissCommaOrSquareBracket, 1, 3, '[1}')
  TkDriver.testDecodeError(TkJson.errorCode.eMissCommaOrSquareBracket, 1, 4, '[1 2')
  TkDriver.testDecodeError(TkJson.errorCode.eMissCommaOrSquareBracket, 1, 4, '[[]')
end

local TestDecodeObject = function()
  TkDriver.testDecodeObject({}, '{}')
  TkDriver.testDecodeObject(
    {
      ['n'] = TkJson.null,
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

local TestDecodeIllegalObject = function()
  TkDriver.testDecodeError(TkJson.errorCode.eMissKey, 1, 2, '{:1,')
  TkDriver.testDecodeError(TkJson.errorCode.eMissKey, 1, 2, '{1:1,')
  TkDriver.testDecodeError(TkJson.errorCode.eMissKey, 1, 2, '{true:1,')
  TkDriver.testDecodeError(TkJson.errorCode.eMissKey, 1, 2, '{false:1,')
  TkDriver.testDecodeError(TkJson.errorCode.eMissKey, 1, 2, '{null:1,')
  TkDriver.testDecodeError(TkJson.errorCode.eMissKey, 1, 2, '{[]:1,')
  TkDriver.testDecodeError(TkJson.errorCode.eMissKey, 1, 2, '{{}:1,')
  TkDriver.testDecodeError(TkJson.errorCode.eMissKey, 1, 8, '{\"a\":1,')

  TkDriver.testDecodeError(TkJson.errorCode.eMissColon, 1, 5, '{\"a\"}')
  TkDriver.testDecodeError(TkJson.errorCode.eMissColon, 1, 5, '{\"a\",\"b\"}')

  TkDriver.testDecodeError(TkJson.errorCode.eMissCommaOrCurlyBracket, 1, 7, '{\"a\":1')
  TkDriver.testDecodeError(TkJson.errorCode.eMissCommaOrCurlyBracket, 1, 7, '{\"a\":1]')
  TkDriver.testDecodeError(TkJson.errorCode.eMissCommaOrCurlyBracket, 1, 8, '{\"a\":1 \"b\"')
  TkDriver.testDecodeError(TkJson.errorCode.eMissCommaOrCurlyBracket, 1, 8, '{\"a\":{}')
end

local TestDecoder = function()
  TestDecodeLiteral()
  TestDecodeIllegalLiteral()
  TestDecodeNumber()
  TestDecodeIllegalNumber()
  TestDecodeString()
  TestDecodeIllegalString()
  TestDecodeArray()
  TestDecodeIllegalArray()
  TestDecodeObject()
  TestDecodeIllegalObject()
end

local TestEncodeLiteral = function()
  TkDriver.testRoundTrip('null')
  TkDriver.testRoundTrip('true')
  TkDriver.testRoundTrip('false')
end

local TestEncodeNumber = function()
  TkDriver.testRoundTrip('0')
  -- TkDriver.testRoundTrip('-0')
  TkDriver.testRoundTrip('1')
  TkDriver.testRoundTrip('-1')
  TkDriver.testRoundTrip('1.5')
  TkDriver.testRoundTrip('-1.5')
  TkDriver.testRoundTrip('3.25')
  TkDriver.testRoundTrip('1e+20')
  TkDriver.testRoundTrip('1.234e+20')
  TkDriver.testRoundTrip('1.234e-20')

  TkDriver.testRoundTrip('1.0000000000000002')
  TkDriver.testRoundTrip('4.9406564584124654e-324')
  TkDriver.testRoundTrip('-4.9406564584124654e-324')
  TkDriver.testRoundTrip('2.2250738585072009e-308')
  TkDriver.testRoundTrip('-2.2250738585072009e-308')
  TkDriver.testRoundTrip('2.2250738585072014e-308')
  TkDriver.testRoundTrip('-2.2250738585072014e-308')
  TkDriver.testRoundTrip('1.7976931348623157e+308')
  TkDriver.testRoundTrip('-1.7976931348623157e+308')
end

local TestEncodeString = function()
  TkDriver.testRoundTrip("\"\"");
  TkDriver.testRoundTrip("\"Hello\"");
  TkDriver.testRoundTrip("\"Hello\\nWorld\"");
  TkDriver.testRoundTrip("\"\\\" \\\\ / \\b \\f \\n \\r \\t\"");
  TkDriver.testRoundTrip("\"Hello\\u0000World\"");
end

local TestEncodeArray = function()
  TkDriver.testRoundTrip('[]')
  TkDriver.testRoundTrip('[null,false,true,123,\"abc\",[1,2,3]]')
end

local TestEncodeObject = function()
  TkDriver.testRoundTrip('{}')
  -- TkDriver.testRoundTrip('{\"n\":null,\"f\":false,\"t\":true,\"i\":123,\"s\":\"abc\",\"a\":[1,2,3],\"o\":{\"1\":1,\"2\":2,\"3\":3}}')
end

local TestEncoder = function()
  TestEncodeLiteral()
  TestEncodeNumber()
  TestEncodeString()
  TestEncodeArray()
  TestEncodeObject()
end

TestDecoder()
TestEncoder()
print('> All Tests Passed!')