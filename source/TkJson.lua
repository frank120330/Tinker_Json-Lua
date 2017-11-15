local TkJson = {}

-- TkJson.errorCode = {
--   eOk = 0,
--   eNotWhitespace = 1,
--   eExpectValue = 2,
--   eInvalidValue = 3,
--   eRootNotSingular = 4,
--   eNumberTooBig = 5,
--   eMissQuotationMark = 6,
--   eInvalidStringEscape = 7,
--   eInvalidStringChar = 8,
--   eInvalidUnicodeHex = 9,
--   eInvalidUnicodeSurrogate = 10,
--   eMissCommaOrSquareBracket = 11,
--   eMissKey = 12,
--   eMissColon = 13,
--   eMissCommaOrCurlyBracket = 14
-- }

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

-- Global variables & functions declarations

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
local decodeUtf8
local encodeUtf8
local parseString
local parseArray
local parseObject

--

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
    '# Error: Line %d Column %d - %s', rowCount, colCount, errorType
  )
  error(errorMsg, 0)
end

local whitespaceString = {
  [' '] = true,
  ['\t'] = true,
  ['\n'] = true,
  ['\r'] = true
}
parseWhitespace = function()
  while whitespaceString[gNextChar] do
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
  return nil
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

local byteZero = string.byte('0')
local byteOne = string.byte('1')
local byteNine = string.byte('9')
local byteUpperA = string.byte('A')
local byteLowerA = string.byte('a')
local byteUpperF = string.byte('F')
local byteLowerF = string.byte('f')

decodeUtf8 = function()
  local hex = 0
  local byte = 0
  for i = 1, 4 do
    gPointer = gPointer + 1
    gNextChar = gIterator()
    if gNextChar == nil then
      return nil
    else
      byte = string.byte(gNextChar)
      hex = hex << 4
      if byte >= byteZero and byte <= byteNine then
        hex = hex | (byte - byteZero)
      elseif byte >= byteUpperA and byte <= byteUpperF then
        hex = hex | (byte - byteUpperA + 10)
      elseif byte >= byteLowerA and byte <= byteLowerF then
        hex = hex | (byte - byteLowerA + 10)
      else
        return nil
      end
    end
  end
  return hex
end

encodeUtf8 = function(hex)
  local value = nil
  if hex <= 0x7F then
    value = string.char(hex & 0xFF)
  elseif hex <= 0x7FF then
    value = string.char(
      (0xC0 | ((hex >> 6) & 0xFF)), 
      (0x80 | (hex & 0x3F))
    )
  elseif hex <= 0xFFFF then
    value = string.char(
      (0xE0 | ((hex >> 12) & 0xFF)),
      (0x80 | ((hex >> 6) & 0x3F)),
      (0x80 | (hex & 0x3F))
    )
  else
    value = string.char(
      (0xF0 | ((hex >> 18) & 0xFF)),
      (0x80 | ((hex >> 12) & 0x3F)),
      (0x80 | ((hex >> 6) & 0x3F)),
      (0x80 | (hex & 0x3F))
    )
  end
  return value
end

local escapeChar = {
  ['\"'] = '\"', ['\\'] = '\\', ['/'] = '/',
  ['b'] = '\b', ['f'] = '\f', ['n'] = '\n',
  ['r'] = '\r', ['t'] = '\t'
}
parseString = function()
  local value = ''
  local startPoint = gPointer + 1
  local stopPoint = gPointer + 1

  while true do
    gPointer = gPointer + 1
    gNextChar = gIterator()
    if gNextChar == nil then
      parseError(TkJson.errorCode.eMissQuotationMark)
    elseif gNextChar == '"' then
      stopPoint = gPointer - 1
      value = value .. string.sub(gString, startPoint, stopPoint)
      gPointer = gPointer + 1
      gNextChar = gIterator()
      return value
    elseif gNextChar == '\\' then
      stopPoint = gPointer - 1
      value = value .. string.sub(gString, startPoint, stopPoint)
      gPointer = gPointer + 1
      gNextChar = gIterator()
      if escapeChar[gNextChar] then
        value = value .. escapeChar[gNextChar]
      elseif gNextChar == 'u' then
        local hex1 = nil
        local hex2 = nil
        hex1 = decodeUtf8()
        if hex1 == nil then
          parseError(TkJson.errorCode.eInvalidUnicodeHex)
        end
        if hex1 >= 0xD800 and hex1 <= 0xDBFF then
          gPointer = gPointer + 1
          gNextChar = gIterator()
          if gNextChar ~= '\\' then
            parseError(TkJson.errorCode.eInvalidUnicodeSurrogate)
          end
          gPointer = gPointer + 1
          gNextChar = gIterator()
          if gNextChar ~= 'u' then
            parseError(TkJson.errorCode.eInvalidUnicodeSurrogate)
          end
          hex2 = decodeUtf8()
          if hex2 == nil then
            parseError(TkJson.errorCode.eInvalidUnicodeHex)
          end
          if hex2 < 0xDC00 or  hex2 > 0xDFFF then
            parseError(TkJson.errorCode.eInvalidUnicodeSurrogate)
          end
          hex1 = (((hex1 - 0xD800) << 10) | (hex2 - 0xDC00)) + 0x10000
        end
        value = value .. encodeUtf8(hex1)
      else
        parseError(TkJson.errorCode.eInvalidStringEscape)
      end
      startPoint = gPointer + 1
    else
      if string.byte(gNextChar) < 0x20 then
        parseError(TkJson.errorCode.eInvalidStringChar)
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
    return valueChar[gNextChar]()
  else
    if gNextChar == nil then
      parseError(TkJson.errorCode.eExpectValue)
    else
      parseError(TkJson.errorCode.eInvalidValue)
    end
  end
end

TkJson.parse = function(jsonString)
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

TkJson.decode = TkJson.parse

return TkJson