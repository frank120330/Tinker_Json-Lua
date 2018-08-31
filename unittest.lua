local TkJson = require('source/TkJson')
local TkDriver = require('source/TkDriver')

local function DecodeLiteral()
  TkDriver.TestDecode(TkJson.null, 'null')
  TkDriver.TestDecode(true, 'true')
  TkDriver.TestDecode(false, 'false')
end

local function DecodeIllegalLiteral()
  TkDriver.TestError(TkJson.ErrorCode.ExpectValue, 1, 1, '')
  TkDriver.TestError(TkJson.ErrorCode.ExpectValue, 1, 2, ' ')

  TkDriver.TestError(TkJson.ErrorCode.InvalidValue, 1, 4, 'nul')
  TkDriver.TestError(TkJson.ErrorCode.InvalidValue, 1, 1, '?')

  TkDriver.TestError(TkJson.ErrorCode.RootNotSingular, 1, 6, 'null x')
end

local function DecodeNumber()
  TkDriver.TestDecode(0.0, '0')
  TkDriver.TestDecode(0.0, '-0')
  TkDriver.TestDecode(0.0, '-0.0')
  TkDriver.TestDecode(1.0, '1')
  TkDriver.TestDecode(-1.0, '-1')
  TkDriver.TestDecode(1.5, '1.5')
  TkDriver.TestDecode(-1.5, '-1.5')
  TkDriver.TestDecode(3.1416, '3.1416')
  TkDriver.TestDecode(1E10, '1E10')
  TkDriver.TestDecode(1e10, '1e10')
  TkDriver.TestDecode(1E+10, '1E+10')
  TkDriver.TestDecode(1E-10, '1E-10')
  TkDriver.TestDecode(-1E10, '-1E10')
  TkDriver.TestDecode(-1e10, '-1e10')
  TkDriver.TestDecode(-1E+10, '-1E+10')
  TkDriver.TestDecode(-1E-10, '-1E-10')
  TkDriver.TestDecode(1.234E+10, '1.234E+10')
  TkDriver.TestDecode(1.234E-10, '1.234E-10')
  TkDriver.TestDecode(0.0, '1e-10000')

  TkDriver.TestDecode(1.0000000000000002, '1.0000000000000002')
  TkDriver.TestDecode( 4.9406564584124654e-324, '4.9406564584124654e-324')
  TkDriver.TestDecode(-4.9406564584124654e-324, '-4.9406564584124654e-324')
  TkDriver.TestDecode( 2.2250738585072009e-308, '2.2250738585072009e-308')
  TkDriver.TestDecode(-2.2250738585072009e-308, '-2.2250738585072009e-308')
  TkDriver.TestDecode( 2.2250738585072014e-308, '2.2250738585072014e-308')
  TkDriver.TestDecode(-2.2250738585072014e-308, '-2.2250738585072014e-308')
  TkDriver.TestDecode( 1.7976931348623157e+308, '1.7976931348623157e+308')
  TkDriver.TestDecode(-1.7976931348623157e+308, '-1.7976931348623157e+308')
end

local function DecodeIllegalNumber()
  TkDriver.TestError(TkJson.ErrorCode.InvalidValue, 1, 1, '+0')
  TkDriver.TestError(TkJson.ErrorCode.InvalidValue, 1, 1, '+1')
  TkDriver.TestError(TkJson.ErrorCode.InvalidValue, 1, 1, '.123')
  -- TkDriver.TestError(TkJson.ErrorCode.InvalidValue, '1.')
  TkDriver.TestError(TkJson.ErrorCode.InvalidValue, 1, 1, 'INF')
  TkDriver.TestError(TkJson.ErrorCode.InvalidValue, 1, 1, 'inf')
  TkDriver.TestError(TkJson.ErrorCode.InvalidValue, 1, 1, 'NAN')
  TkDriver.TestError(TkJson.ErrorCode.InvalidValue, 1, 2, 'nan')

  TkDriver.TestError(TkJson.ErrorCode.NumberTooBig, 1, 6, '1e309')
  TkDriver.TestError(TkJson.ErrorCode.NumberTooBig, 1, 7, '-1e309')
  -- TkDriver.TestError(TkJson.ErrorCode.RootNotSingular, '0123')
  TkDriver.TestError(TkJson.ErrorCode.RootNotSingular, 1, 2, '0x0')
  TkDriver.TestError(TkJson.ErrorCode.RootNotSingular, 1, 2, '0x123')
end

local function DecodeString()
  TkDriver.TestDecode('', '\"\"')
  TkDriver.TestDecode('Hello', '\"Hello\"')
  TkDriver.TestDecode('Hello\nWorld', '\"Hello\\nWorld\"')
  TkDriver.TestDecode('\" \\ / \b \f \n \r \t', '\"\\\" \\\\ \\/ \\b \\f \\n \\r \\t\"')
  TkDriver.TestDecode('Hello\0World', '\"Hello\\u0000World\"')
  TkDriver.TestDecode('\x24', '\"\\u0024\"')
  TkDriver.TestDecode('\xC2\xA2', '\"\\u00A2\"')
  TkDriver.TestDecode('\xE2\x82\xAC', '\"\\u20AC\"')
  TkDriver.TestDecode('\xF0\x9D\x84\x9E', '\"\\uD834\\uDD1E\"')
  TkDriver.TestDecode('\xF0\x9D\x84\x9E', '\"\\ud834\\udd1e\"')
end

local function DecodeIllegalString()
  TkDriver.TestError(TkJson.ErrorCode.MissQuotationMark, 1, 2, '\"')
  TkDriver.TestError(TkJson.ErrorCode.MissQuotationMark, 1, 5, '\"abc')
  TkDriver.TestError(TkJson.ErrorCode.InvalidStringEscape, 1, 3, '\"\\v\"')
  TkDriver.TestError(TkJson.ErrorCode.InvalidStringEscape, 1, 3, '\"\\;\"')
  TkDriver.TestError(TkJson.ErrorCode.InvalidStringEscape, 1, 3, '\"\\0\"')
  TkDriver.TestError(TkJson.ErrorCode.InvalidStringEscape, 1, 3, '\"\\x12\"')
  TkDriver.TestError(TkJson.ErrorCode.InvalidStringChar, 1, 3, '\"\x01\"')
  TkDriver.TestError(TkJson.ErrorCode.InvalidStringChar, 1, 3, '\"\x1F\"')
end

local function DecodeArray()
  TkDriver.TestDecode(
    { TkJson.null, false, true, 123, 'abc', __length = 5 }, 
    '[ null , false , true , 123 , \"abc\" ]'
  )
  TkDriver.TestDecode({ __length = 0 }, '[ ]')
  TkDriver.TestDecode(
    { 
      { __length = 0 }, 
      { 0, __length = 1 }, 
      { 0, 1, __length = 2 }, 
      { 0, 1, 2, __length = 3 }, 
      __length = 4 
    }, 
    '[ [ ] , [ 0 ] , [ 0 , 1 ] , [ 0 , 1 , 2 ] ]'
  )
end

local function DecodeIllegalArray()
  TkDriver.TestError(TkJson.ErrorCode.MissCommaOrSquareBracket, 1, 3, '[1')
  TkDriver.TestError(TkJson.ErrorCode.MissCommaOrSquareBracket, 1, 3, '[1}')
  TkDriver.TestError(TkJson.ErrorCode.MissCommaOrSquareBracket, 1, 4, '[1 2')
  TkDriver.TestError(TkJson.ErrorCode.MissCommaOrSquareBracket, 1, 4, '[[]')
end

local function DecodeObject()
  TkDriver.TestDecode({}, '{}')
  TkDriver.TestDecode(
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

local function DecodeIllegalObject()
  TkDriver.TestError(TkJson.ErrorCode.MissKey, 1, 2, '{:1,')
  TkDriver.TestError(TkJson.ErrorCode.MissKey, 1, 2, '{1:1,')
  TkDriver.TestError(TkJson.ErrorCode.MissKey, 1, 2, '{true:1,')
  TkDriver.TestError(TkJson.ErrorCode.MissKey, 1, 2, '{false:1,')
  TkDriver.TestError(TkJson.ErrorCode.MissKey, 1, 2, '{null:1,')
  TkDriver.TestError(TkJson.ErrorCode.MissKey, 1, 2, '{[]:1,')
  TkDriver.TestError(TkJson.ErrorCode.MissKey, 1, 2, '{{}:1,')
  TkDriver.TestError(TkJson.ErrorCode.MissKey, 1, 8, '{\"a\":1,')

  TkDriver.TestError(TkJson.ErrorCode.MissColon, 1, 5, '{\"a\"}')
  TkDriver.TestError(TkJson.ErrorCode.MissColon, 1, 5, '{\"a\",\"b\"}')

  TkDriver.TestError(TkJson.ErrorCode.MissCommaOrCurlyBracket, 1, 7, '{\"a\":1')
  TkDriver.TestError(TkJson.ErrorCode.MissCommaOrCurlyBracket, 1, 7, '{\"a\":1]')
  TkDriver.TestError(TkJson.ErrorCode.MissCommaOrCurlyBracket, 1, 8, '{\"a\":1 \"b\"')
  TkDriver.TestError(TkJson.ErrorCode.MissCommaOrCurlyBracket, 1, 8, '{\"a\":{}')
end

local function TestDecode()
  DecodeLiteral()
  DecodeIllegalLiteral()
  DecodeNumber()
  DecodeIllegalNumber()
  DecodeString()
  DecodeIllegalString()
  DecodeArray()
  DecodeIllegalArray()
  DecodeObject()
  DecodeIllegalObject()
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

TestDecode()
-- TestEncoder()
print('> All Tests Passed!')