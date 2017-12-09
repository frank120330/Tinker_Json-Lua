local TkJson = {}

--[[
  We use an anonymous function to define a `null` in Lua.
--]]

TkJson.null = function() end

TkJson.errorCode = {
  eOk = 'Decode successfully',
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
  Global variables & functions used by multiple decoding functions.
--]]

local gIterator = nil
local gNextChar = nil
local gPointer = nil
local gString = nil

--[[
  Decoding functions for different data types.
--]]

local decodeError
local decodeWhitespace
local decodeValue
local decodeNull
local decodeTrue
local decodeFalse
local decodeNumber
local decodeUnicode
local decodeString
local decodeArray
local decodeObject
local decode

decodeError = function(errorType)
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
decodeWhitespace = function()
  while whitespaceChar[gNextChar] do
    gPointer = gPointer + 1
    gNextChar = gIterator()
  end
end

local nullChar = {
  'n', 'u', 'l', 'l'
}
decodeNull = function()
  for i = 1, 4 do
    if gNextChar ~= nullChar[i] then
      decodeError(TkJson.errorCode.eInvalidValue)
    end
    gPointer = gPointer + 1
    gNextChar = gIterator()
  end
  return TkJson.null
end

local trueChar = {
  't', 'r', 'u', 'e'
}
decodeTrue = function()
  for i = 1, 4 do
    if gNextChar ~= trueChar[i] then
      decodeError(TkJson.errorCode.eInvalidValue)
    end
    gPointer = gPointer + 1
    gNextChar = gIterator()
  end
  return true
end

local falseChar = {
  'f', 'a', 'l', 's', 'e'
}
decodeFalse = function()
  for i = 1, 5 do
    if gNextChar ~= falseChar[i] then
      decodeError(TkJson.errorCode.eInvalidValue)
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
decodeNumber = function()
  local startPoint = gPointer
  while numberChar[gNextChar] do
    gPointer = gPointer + 1
    gNextChar = gIterator()
  end

  local stopPoint = gPointer - 1
  local value = tonumber(string.sub(gString, startPoint, stopPoint))
  if value == nil then
    decodeError(TkJson.errorCode.eInvalidValue)
  elseif value == math.huge or value == -math.huge then
    decodeError(TkJson.errorCode.eNumberTooBig)
  else
    return value
  end
end

decodeUnicode = function(utf8String)
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
decodeString = function()
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
        decodeError(TkJson.errorCode.eInvalidStringChar)
      end
      if hasSurrogate then
        value = string.gsub(value, '\\u[dD][89AaBb]..\\u....', decodeUnicode)
      end
      if hasUnicode then
        value = string.gsub(value, '\\u....', decodeUnicode)
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
          decodeError(TkJson.errorCode.eInvalidUnicodeHex)
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
          decodeError(TkJson.errorCode.eInvalidStringEscape)
        else
          hasEscape = true
        end
      end
    else
      if gNextChar == nil then
        decodeError(TkJson.errorCode.eMissQuotationMark)
      end
    end
  end
end

decodeArray = function()
  local value = {
    __length = 0
  }
  local length = 0
  
  gPointer = gPointer + 1
  gNextChar = gIterator()
  decodeWhitespace()
  if gNextChar == ']' then
    gPointer = gPointer + 1
    gNextChar = gIterator()
    return value
  end
  while true do
    local element = nil
    element = decodeValue()
    length = length + 1
    value[length] = element
    decodeWhitespace()
    if gNextChar == ',' then
      gPointer = gPointer + 1
      gNextChar = gIterator()
      decodeWhitespace()
    elseif gNextChar == ']' then
      value.__length = length
      gPointer = gPointer + 1
      gNextChar = gIterator()
      return value
    else
      decodeError(TkJson.errorCode.eMissCommaOrSquareBracket)
    end
  end
end

decodeObject = function()
  local value = {}

  gPointer = gPointer + 1
  gNextChar = gIterator()
  decodeWhitespace()
  if gNextChar == '}' then
    gPointer = gPointer + 1
    gNextChar = gIterator()
    return value
  end
  while true do
    local key = nil
    local element = nil

    if gNextChar ~= '"' then
      decodeError(TkJson.errorCode.eMissKey)
    end
    key = decodeString()
    decodeWhitespace()
    if gNextChar ~= ':' then
      decodeError(TkJson.errorCode.eMissColon)
    end
    gPointer = gPointer + 1
    gNextChar = gIterator()
    decodeWhitespace()
    element = decodeValue()
    value[key] = element
    decodeWhitespace()
    if gNextChar == ',' then
      gPointer = gPointer + 1
      gNextChar = gIterator()
      decodeWhitespace()
    elseif gNextChar == '}' then
      gPointer = gPointer + 1
      gNextChar = gIterator()
      return value
    else
      decodeError(TkJson.errorCode.eMissCommaOrCurlyBracket)
    end
  end
end

local valueChar = {
  ['n'] = decodeNull, ['t'] = decodeTrue, ['f'] = decodeFalse,
  ['"'] = decodeString, ['['] = decodeArray, ['{'] = decodeObject, 
  ['-'] = decodeNumber, ['0'] = decodeNumber, ['1'] = decodeNumber,
  ['2'] = decodeNumber, ['3'] = decodeNumber, ['4'] = decodeNumber,
  ['5'] = decodeNumber, ['6'] = decodeNumber, ['7'] = decodeNumber,
  ['8'] = decodeNumber, ['9'] = decodeNumber
}
decodeValue = function()
  if valueChar[gNextChar] then
    local decodeFunc = valueChar[gNextChar]
    return decodeFunc()
  else
    if gNextChar == nil then
      decodeError(TkJson.errorCode.eExpectValue)
    else
      decodeError(TkJson.errorCode.eInvalidValue)
    end
  end
end

decode = function(jsonString)
  local value = nil
  
  gIterator = string.gmatch(jsonString, '.')
  gNextChar = gIterator()
  gPointer = 1
  gString = jsonString

  decodeWhitespace()
  value = decodeValue()
  decodeWhitespace()

  if gNextChar ~= nil then
    decodeError(TkJson.errorCode.eRootNotSingular)
  end
  return value
end

--[[
  JSON decoding API exposed to users  
--]]

TkJson.parser = decode
TkJson.decode = decode

--[[
  Global Constants & functions used by Stringifier
--]]

local encodeNull
local encodeBoolean
local encodeNumber
local encodeString
local encodeTable
local encodeArray
local encodeObject
local encode

--[[
  Stringification functions
--]]

encodeNull = function(value)
  return 'null'
end

encodeBoolean = function(value)
  if value then
    return 'true'
  else
    return 'false'
  end
end

encodeNumber = function(value)
  return string.format('%.17g', value)
end

local stringValue = {
  -- ['"'] = true, ['\\'] = true, ['/'] = true,
  -- ['b'] = true, ['f'] = true, ['n'] = true,
  -- ['r'] = true, ['t'] = true, ['u'] = true
  ['\"'] = '\\"', ['\\'] = '\\\\', ['/'] = '/',
  ['\b'] = '\\b', ['\f'] = '\\f', ['\n'] = '\\n',
  ['\r'] = '\\r', ['\t'] = '\\t'
}
local utf8Replacer = function(ch)
  return string.format('\\u%04X', string.byte(ch))
end
encodeString = function(value)
  local result = '"' .. string.gsub(value, '[\"\\/\b\f\n\r\t]', stringValue) .. '"'
  result = string.gsub(result, '[\x00-\x1F]', utf8Replacer)
  return result
end

encodeArray = function(value)
  local stringArray = {}
  local length = value.__length
  for i = 1, length do
    table.insert(stringArray, encode(value[i]))
  end
  return '[' .. table.concat(stringArray, ',') .. ']'
end

encodeObject = function(value)
  local stringArray = {}
  for key, val in pairs(value) do
    table.insert(stringArray, encode(key) .. ':' .. encode(val))
  end
  return '{' .. table.concat(stringArray, ',') .. '}'
end

encodeTable = function(value)
  if value.__length then
    return encodeArray(value)
  else
    return encodeObject(value)
  end
end

local encodeChar = {
  ['function'] = encodeNull, 
  ['boolean'] = encodeBoolean,
  ['number'] = encodeNumber,
  ['string'] = encodeString,
  ['table'] = encodeTable
}
encode = function(value)
  local encodeFunc = encodeChar[type(value)]
  if encodeFunc then
    return encodeFunc(value)
  else
    error('# Error: Invalid data type ' .. tostring(value))
  end
end

TkJson.encode = encode
TkJson.encode = encode

return TkJson