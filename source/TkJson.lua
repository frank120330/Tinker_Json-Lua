local TkJson = {}

--[[
  Constants for JSON parser
--]]

TkJson.null = function() {}

TkJson.errorCode = {
  eOk = 'Parsed successfully',
  eExpectValue = 'Expect a value',
  eInvalidValue = 'Invalid value',
  eRootNotSingular = 'Root not singular',
  eNumberTooBig = 'Number too big',
  eMissQuotationMark = 'Miss quotation mark',
  eInvalidStringEscape = 'Invalid string escape',
  eInvalidStringChar = 'Invalid string char',
  eInvalidUnicodeHex = 'Invalid unicode hex',
  eInvalidUnicodeSurrogate = 'Invalid unicode surrogate',
  eMissCommaOrSquareBracket = 'Miss comma or square bracket',
  eMissKey = 'Miss key in key-value pair',
  eMissColon = 'Miss colon',
  eMissCommaOrCurlyBracket = 'Miss comma or curly bracket'
}

--[[
  Global variables & functions used by JSON parser
--]]

local gIterator = nil
local gNextChar = nil
local gPointer = nil
local gString = nil

local parseError
local parseWhitespace
local parseValue
local parseNull
local parseTrue
local parseFalse
local parseNumber
local parseUnicode
local parseString
local parseArray
local parseObject
local parse

--[[
  Parsing functions
--]]

parseError = function(errorType)
  local rowCount = 1
  local colCount = 1
  
  local iterator = string.gmatch(gString, '.')
  local nextChar = iterator()
  local pointer = 1

  while pointer < gPointer do
    pointer = pointer + 1
    nextChar = iterator()
    if nextChar == '\n' then
      rowCount = rowCount + 1
      colCount = 1
    else
      colCount = colCount + 1
    end
  end

  local errorMsg = string.format(
    '# Error: Line %d Column %d - %s', 
    rowCount, colCount, errorType
  )
  error(errorMsg, 0)
end

local whitespaceChar = {
  [' '] = true, ['\t'] = true,
  ['\n'] = true, ['\r'] = true
}
parseWhitespace = function()
  while whitespaceChar[gNextChar] do
    gPointer = gPointer + 1
    gNextChar = gIterator()
  end
end

local nullChar = {
  'n', 'u', 'l', 'l'
}
parseNull = function()
  for i = 1, 4 do
    if gNextChar ~= nullChar[i] then
      parseError(TkJson.errorCode.eInvalidValue)
    end
    gPointer = gPointer + 1
    gNextChar = gIterator()
  end
  return TkJson.null
end

local trueChar = {
  't', 'r', 'u', 'e'
}
parseTrue = function()
  for i = 1, 4 do
    if gNextChar ~= trueChar[i] then
      parseError(TkJson.errorCode.eInvalidValue)
    end
    gPointer = gPointer + 1
    gNextChar = gIterator()
  end
  return true
end

local falseChar = {
  'f', 'a', 'l', 's', 'e'
}
parseFalse = function()
  for i = 1, 5 do
    if gNextChar ~= falseChar[i] then
      parseError(TkJson.errorCode.eInvalidValue)
    end
    gPointer = gPointer + 1
    gNextChar = gIterator()
  end
  return false
end

local numberChar = {
  ['0'] = true, ['1'] = true, ['2'] = true, ['3'] = true, ['4'] = true, 
  ['5'] = true, ['6'] = true, ['7'] = true, ['8'] = true, ['9'] = true,
  ['+'] = true, ['-'] = true, ['.'] = true, ['e'] = true, ['E'] = true
}
parseNumber = function()
  local startPoint = gPointer
  while numberChar[gNextChar] do
    gPointer = gPointer + 1
    gNextChar = gIterator()
  end

  local stopPoint = gPointer - 1
  local value = tonumber(string.sub(gString, startPoint, stopPoint))
  if value == nil then
    parseError(TkJson.errorCode.eInvalidValue)
  elseif value == math.huge or value == -math.huge then
    parseError(TkJson.errorCode.eNumberTooBig)
  else
    return value
  end
end

parseUnicode = function(utf8String)
  local hex1 = tonumber(string.sub(utf8String, 3, 6), 16)
  local hex2 = tonumber(string.sub(utf8String, 9, 12), 16)
  if hex2 then
    hex1 = (((hex1 - 0xD800) << 10) | (hex2 - 0xDC00)) + 0x10000
  end

  if hex1 <= 0x7F then
    return string.char(hex1 & 0xFF)
  elseif hex1 <= 0x7FF then
    return string.char(
      (0xC0 | ((hex1 >> 6) & 0xFF)), 
      (0x80 | (hex1 & 0x3F))
    )
  elseif hex1 <= 0xFFFF then
    return string.char(
      (0xE0 | ((hex1 >> 12) & 0xFF)),
      (0x80 | ((hex1 >> 6) & 0x3F)),
      (0x80 | (hex1 & 0x3F))
    )
  else
    return string.char(
      (0xF0 | ((hex1 >> 18) & 0xFF)),
      (0x80 | ((hex1 >> 12) & 0x3F)),
      (0x80 | ((hex1 >> 6) & 0x3F)),
      (0x80 | (hex1 & 0x3F))
    )
  end
end

local escapeChar = {
  ['"'] = true, ['\\'] = true, ['/'] = true,
  ['b'] = true, ['f'] = true, ['n'] = true,
  ['r'] = true, ['t'] = true
}
local escapeValue = {
  ['\\\"'] = '\"', ['\\\\'] = '\\', ['\\/'] = '/',
  ['\\b'] = '\b', ['\\f'] = '\f', ['\\n'] = '\n',
  ['\\r'] = '\r', ['\\t'] = '\t'
}
parseString = function()
  local value = ''
  local startPoint = gPointer + 1
  local stopPoint = gPointer + 1
  local hasSurrogate = false
  local hasUnicode = false
  local hasEscape = false

  while true do
    gPointer = gPointer + 1
    gNextChar = gIterator()
    if gNextChar == '"' then
      stopPoint = gPointer - 1
      value = string.sub(gString, startPoint, stopPoint)
      if string.find(value, '[\x01-\x1F]') then
        parseError(TkJson.errorCode.eInvalidStringChar)
      end
      if hasSurrogate then
        value = string.gsub(value, '\\u[dD][89AaBb]..\\u....', parseUnicode)
      end
      if hasUnicode then
        value = string.gsub(value, '\\u....', parseUnicode)
      end
      if hasEscape then
        value = string.gsub(value, '\\.', escapeValue)
      end
      gPointer = gPointer + 1
      gNextChar = gIterator()
      return value
    elseif gNextChar == '\\' then
      gPointer = gPointer + 1
      gNextChar = gIterator()

      if gNextChar == 'u' then
        local hexString = string.sub(gString, gPointer + 1, gPointer + 4)
        if not string.find(hexString, '%x%x%x%x') then
          parseError(TkJson.errorCode.eInvalidUnicodeHex)
        end
        if string.find(hexString, '^[Dd][89AaBb]') then
          hasSurrogate = true
          for i = 1, 10 do
            gPointer = gPointer + 1
            gNextChar = gIterator()
          end
        else
          hasUnicode = true
          for i = 1, 4 do
            gPointer = gPointer + 1
            gNextChar = gIterator()
          end
        end
      else
        if not escapeChar[gNextChar] then
          parseError(TkJson.errorCode.eInvalidStringEscape)
        else
          hasEscape = true
        end
      end
    else
      if gNextChar == nil then
        parseError(TkJson.errorCode.eMissQuotationMark)
      end
    end
  end
end

parseArray = function()
  local value = {
    __length = 0
  }
  local length = 0
  
  gPointer = gPointer + 1
  gNextChar = gIterator()
  parseWhitespace()
  if gNextChar == ']' then
    gPointer = gPointer + 1
    gNextChar = gIterator()
    return value
  end
  while true do
    local element = nil
    element = parseValue()
    length = length + 1
    value[length] = element
    parseWhitespace()
    if gNextChar == ',' then
      gPointer = gPointer + 1
      gNextChar = gIterator()
      parseWhitespace()
    elseif gNextChar == ']' then
      value.__length = length
      gPointer = gPointer + 1
      gNextChar = gIterator()
      return value
    else
      parseError(TkJson.errorCode.eMissCommaOrSquareBracket)
    end
  end
end

parseObject = function()
  local value = {}

  gPointer = gPointer + 1
  gNextChar = gIterator()
  parseWhitespace()
  if gNextChar == '}' then
    gPointer = gPointer + 1
    gNextChar = gIterator()
    return value
  end
  while true do
    local key = nil
    local element = nil

    if gNextChar ~= '"' then
      parseError(TkJson.errorCode.eMissKey)
    end
    key = parseString()
    parseWhitespace()
    if gNextChar ~= ':' then
      parseError(TkJson.errorCode.eMissColon)
    end
    gPointer = gPointer + 1
    gNextChar = gIterator()
    parseWhitespace()
    element = parseValue()
    value[key] = element
    parseWhitespace()
    if gNextChar == ',' then
      gPointer = gPointer + 1
      gNextChar = gIterator()
      parseWhitespace()
    elseif gNextChar == '}' then
      gPointer = gPointer + 1
      gNextChar = gIterator()
      return value
    else
      parseError(TkJson.errorCode.eMissCommaOrCurlyBracket)
    end
  end
end

local valueChar = {
  ['n'] = parseNull, ['t'] = parseTrue, ['f'] = parseFalse,
  ['"'] = parseString, ['['] = parseArray, ['{'] = parseObject, 
  ['-'] = parseNumber, ['0'] = parseNumber, ['1'] = parseNumber,
  ['2'] = parseNumber, ['3'] = parseNumber, ['4'] = parseNumber,
  ['5'] = parseNumber, ['6'] = parseNumber, ['7'] = parseNumber,
  ['8'] = parseNumber, ['9'] = parseNumber
}
parseValue = function()
  if valueChar[gNextChar] then
    local parseFunc = valueChar[gNextChar]
    return parseFunc()
  else
    if gNextChar == nil then
      parseError(TkJson.errorCode.eExpectValue)
    else
      parseError(TkJson.errorCode.eInvalidValue)
    end
  end
end

parse = function(jsonString)
  local value = nil
  
  gIterator = string.gmatch(jsonString, '.')
  gNextChar = gIterator()
  gPointer = 1
  gString = jsonString

  parseWhitespace()
  value = parseValue()
  parseWhitespace()

  if gNextChar ~= nil then
    parseError(TkJson.errorCode.eRootNotSingular)
  end
  return value
end

--[[
  JSON Parser API exposed to users  
--]]

TkJson.parse = parse
TkJson.decode = parse

--[[
  Global Constants & functions used by Stringifier
--]]

local stringifyNil
local stringifyBoolean
local stringifyNumber
local stringifyString
local stringifyTable
local stringifyArray
local stringifyObject
local stringify

--[[
  Stringification functions
--]]

stringifyNil = function(value)
  return 'null'
end

stringifyBoolean = function(value)
  if value then
    return 'true'
  else
    return 'false'
  end
end

stringifyNumber = function(value)
  return tostring(value)
end

stringifyString = function(value)
  return value
end

stringifyArray = function(value)
  local str = '['
  local length = value.__length
  for i = 1, length do
    str = str .. stringify(value[i]) .. ','
  end
  if length > 0 then
    str = string.sub(str, 1, -2)
  end
  str = str .. ']'
  return str
end

stringifyObject = function(value)
  local str = '{'
  for k, v in pairs(value) do
    str = str .. stringify(k)
    str = str .. ':'
    str = str .. stringify(v)
    str = str .. ','
  end
  if string.sub(str, -1) == ',' then
    str = string.sub(str, 1, -2)
  end
  str = str .. '}'
  return str
end

stringifyTable = function(value)
  if value.__length then
    return stringifyArray(value)
  else
    return stringifyObject(value)
  end
end

local stringifyChar = {
  ['nil'] = stringifyNil, 
  ['boolean'] = stringifyBoolean,
  ['number'] = stringifyNumber,
  ['string'] = stringifyString,
  ['table'] = stringifyTable
}
stringify = function(value)
  if stringifyChar[type(value)] then
    local stringifyFunc = stringifyChar[type(value)]
    return stringifyFunc(value)
  else
    error('# Error - Invalid data type!')
  end
end

TkJson.stringify = stringify
TkJson.encode = stringify

return TkJson