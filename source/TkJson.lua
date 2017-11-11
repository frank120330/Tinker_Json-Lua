local TkJson = {}

TkJson.errorCode = {
  eOk = 0,
  eNotWhitespace = 1,
  eExpectValue = 2,
  eInvalidValue = 3,
  eRootNotSingular = 4,
  eNumberTooBig = 5,
  eMissQuotationMark = 6,
  eInvalidStringEscape = 7,
  eInvalidStringChar = 8,
  eInvalidUnicodeHex = 9,
  eInvalidUnicodeSurrogate = 10,
  eMissCommaOrSquareBracket = 11,
  eMissKey = 12,
  eMissColon = 13,
  eMissCommaOrCurlyBracket = 14
}

-- Global variables & functions declarations

local gIterator = nil
local gNextChar = nil

local parseWhitespace
local parseValue
local parseNull
local parseTrue
local parseFalse
local isPlus
local isDigit
local parseNumber
local decodeUtf8
local encodeUtf8
local parseString
local parseArray
local parseObject

--

parseWhitespace = function()
  while gNextChar == ' ' or
    gNextChar == '\t' or
    gNextChar == '\n' or
    gNextChar == '\r' do
    gNextChar = gIterator()
  end
end

local nullString = {
  'n', 'u', 'l', 'l'
}
parseNull = function()
  for i = 1, 4 do
    if gNextChar ~= nullString[i] then
      return TkJson.errorCode.eInvalidValue, nil
    end
    gNextChar = gIterator()
  end
  return TkJson.errorCode.eOk, nil
end

local trueString = {
  't', 'r', 'u', 'e'
}
parseTrue = function()
  for i = 1, 4 do
    if gNextChar ~= trueString[i] then
      return TkJson.errorCode.eInvalidValue, nil
    end
    gNextChar = gIterator()
  end
  return TkJson.errorCode.eOk, true
end

local falseString = {
  'f', 'a', 'l', 's', 'e'
}
parseFalse = function()
  for i = 1, 5 do
    if gNextChar ~= falseString[i] then
      return TkJson.errorCode.eInvalidValue, nil
    end
    gNextChar = gIterator()
  end
  return TkJson.errorCode.eOk, false
end

local byteZero = string.byte('0')
local byteOne = string.byte('1')
local byteNine = string.byte('9')

isPlus = function()
  if gNextChar then
    local byteCode = string.byte(gNextChar)
    return (byteCode >= byteOne and byteCode <= byteNine)
  else
    return false
  end
end

isDigit = function()
  if gNextChar then
    local byteCode = string.byte(gNextChar)
    return (byteCode >= byteZero and byteCode <= byteNine)
  else
    return false
  end
end

parseNumber = function()
  local numberString = ''
  if gNextChar == '-' then
    numberString = numberString .. gNextChar
    gNextChar = gIterator()
  end
  if gNextChar == '0' then
    numberString = numberString .. gNextChar
    gNextChar = gIterator()
  else 
    if not isPlus() then
      return TkJson.errorCode.eInvalidValue, nil
    end
    repeat
      numberString = numberString .. gNextChar
      gNextChar = gIterator()
    until (not isDigit())
  end
  if gNextChar == '.' then
    numberString = numberString .. gNextChar
    gNextChar = gIterator()
    if not isDigit() then
      return TkJson.errorCode.eInvalidValue, nil
    end
    repeat
      numberString = numberString .. gNextChar
      gNextChar = gIterator()
    until (not isDigit())
  end
  if gNextChar == 'e' or 
    gNextChar == 'E' then
      numberString = numberString .. gNextChar
      gNextChar = gIterator()
    if gNextChar == '+' or
      gNextChar == '-' then
      numberString = numberString .. gNextChar
      gNextChar = gIterator()
    end
    if not isDigit() then
      return TkJson.errorCode.eInvalidValue, nil
    end
    repeat
      numberString = numberString .. gNextChar
      gNextChar = gIterator()
    until (not isDigit())
  end

  local value = tonumber(numberString)
  if value == math.huge or value == -math.huge then
    return TkJson.errorCode.eNumberTooBig, nil
  else
    return TkJson.errorCode.eOk,  value
  end
end

local byteUpperA = string.byte('A')
local byteLowerA = string.byte('a')
local byteUpperF = string.byte('F')
local byteLowerF = string.byte('f')

decodeUtf8 = function()
  local hex = 0
  local byte = 0
  for i = 1, 4 do
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
    gNextChar = gIterator()
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

parseString = function()
  local value = ''

  gNextChar = gIterator()
  while true do
    local ch = gNextChar
    gNextChar = gIterator()
    if ch == nil then
      return TkJson.errorCode.eMissQuotationMark, nil
    elseif ch == '"' then
      return TkJson.errorCode.eOk, value
    elseif ch == '\\' then
      ch = gNextChar
      gNextChar = gIterator()
      if ch == '\"' then
        value = value .. '\"'
      elseif ch == '\\' then
        value = value .. '\\'
      elseif ch == '/' then
        value = value .. '/'
      elseif ch == 'b' then
        value = value .. '\b'
      elseif ch == 'f' then
        value = value .. '\f'
      elseif ch == 'n' then
        value = value .. '\n'
      elseif ch == 'r' then
        value = value .. '\r'
      elseif ch == 't' then
        value = value .. '\t'
      elseif ch == 'u' then
        local hex1 = nil
        local hex2 = nil
        hex1 = decodeUtf8()
        if hex1 == nil then
          return TkJson.errorCode.eInvalidUnicodeHex, nil
        end
        if hex1 >= 0xD800 and hex1 <= 0xDBFF then
          ch = gNextChar
          gNextChar = gIterator()
          if ch ~= '\\' then
            return TkJson.errorCode.eInvalidUnicodeSurrogate, nil
          end
          ch = gNextChar
          gNextChar = gIterator()
          if ch ~= 'u' then
            return TkJson.errorCode.eInvalidUnicodeSurrogate, nil
          end
          hex2 = decodeUtf8()
          if hex2 == nil then
            return TkJson.errorCode.eInvalidUnicodeHex, nil
          end
          if hex2 < 0xDC00 or  hex2 > 0xDFFF then
            return TkJson.errorCode.eInvalidUnicodeSurrogate, nil
          end
          hex1 = (((hex1 - 0xD800) << 10) | (hex2 - 0xDC00)) + 0x10000
        end
        value = value .. encodeUtf8(hex1)
      else
        return TkJson.errorCode.eInvalidStringEscape, nil
      end
    else
      if string.byte(ch) < 0x20 then
        return TkJson.errorCode.eInvalidStringChar, nil
      else
        value = value .. ch
      end
    end
  end
end

parseArray = function()
  local result = TkJson.errorCode.eOk
  local value = {
    __length = 0
  }
  
  gNextChar = gIterator()
  parseWhitespace()
  if gNextChar == ']' then
    gNextChar = gIterator()
    return result, value
  end
  while true do
    local element = nil
    result, element = parseValue()
    if result ~= TkJson.errorCode.eOk then
      return result, nil
    else
      value.__length = value.__length + 1
      value[value.__length] = element
      parseWhitespace()
      if gNextChar == ',' then
        gNextChar = gIterator()
        parseWhitespace()
      elseif gNextChar == ']' then
        gNextChar = gIterator()
        return result, value
      else
        return TkJson.errorCode.eMissCommaOrSquareBracket, nil
      end
    end
  end
end

parseObject = function()
  local result = TkJson.errorCode.eOk
  local value = {}

  gNextChar = gIterator()
  parseWhitespace()
  if gNextChar == '}' then
    gNextChar = gIterator()
    return result, value
  end
  while true do
    local key = nil
    local element = nil

    if gNextChar ~= '"' then
      return TkJson.errorCode.eMissKey, nil
    end
    result, key = parseString()
    if result ~= TkJson.errorCode.eOk then
      return result, nil
    end
    parseWhitespace()
    if gNextChar ~= ':' then
      return TkJson.errorCode.eMissColon, nil
    end
    gNextChar = gIterator()
    parseWhitespace()
    result, element = parseValue()
    if result ~= TkJson.errorCode.eOk then
      return result, nil
    end
    value[key] = element
    parseWhitespace()
    if gNextChar == ',' then
      gNextChar = gIterator()
      parseWhitespace()
    elseif gNextChar == '}' then
      gNextChar = gIterator()
      return result, value
    else
      return TkJson.errorCode.eMissCommaOrCurlyBracket, nil
    end
  end
end

parseValue = function()
  if gNextChar == nil then
    return TkJson.errorCode.eExpectValue, nil
  elseif gNextChar == 'n' then
    return parseNull()
  elseif gNextChar == 't' then
    return parseTrue()
  elseif gNextChar == 'f' then
    return parseFalse()
  elseif gNextChar == '"' then
    return parseString()
  elseif gNextChar == '[' then
    return parseArray()
  elseif gNextChar == '{' then
    return parseObject()
  else
    return parseNumber()
  end
end

TkJson.parse = function(jsonString)
  local result = TkJson.errorCode.eExpectValue
  local value = nil
  
  gIterator = string.gmatch(jsonString, utf8.charpattern)
  gNextChar = gIterator()

  parseWhitespace()
  result, value = parseValue()
  if result == TkJson.errorCode.eOk then
    parseWhitespace()
    if gNextChar ~= nil then
      result = TkJson.errorCode.eRootNotSingular
      value = nil
    end
  end
  return result, value
end

return TkJson