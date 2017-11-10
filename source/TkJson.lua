local TkJson = {}

-- Type codes & Error codes

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
  eMissCommaOrSquareBracket = 11
}

TkJson.typeCode = {
  eEmpty = 0,
  eWhitespace = 1,
  eValue = 2,
  eNull = 3,
  eTrue = 4,
  eFalse = 5,
  eNumber = 6,
  eString = 7,
  eArray = 8,
  eObject = 9
}

-- Global variables & local functions declaration

local gCharArray = {}
local gCharPointer = 1

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

-- Parser functions

function parseWhitespace()
  while gCharArray[gCharPointer] == ' ' or
    gCharArray[gCharPointer] == '\t' or
    gCharArray[gCharPointer] == '\n' or
    gCharArray[gCharPointer] == '\r' do
    gCharPointer = gCharPointer + 1
  end
end

function parseNull()
  local nullString = {
    'n', 'u', 'l', 'l'
  }
  for i = 1, 4 do
    if gCharArray[gCharPointer] ~= nullString[i] then
      return TkJson.errorCode.eInvalidValue, nil
    end
    gCharPointer = gCharPointer + 1
  end
  return TkJson.errorCode.eOk, nil
end

function parseTrue()
  local trueString = {
    't', 'r', 'u', 'e'
  }
  for i = 1, 4 do
    if gCharArray[gCharPointer] ~= trueString[i] then
      return TkJson.errorCode.eInvalidValue, nil
    end
    gCharPointer = gCharPointer + 1
  end
  return TkJson.errorCode.eOk, true
end

function parseFalse()
  local falseString = {
    'f', 'a', 'l', 's', 'e'
  }
  for i = 1, 5 do
    if gCharArray[gCharPointer] ~= falseString[i] then
      return TkJson.errorCode.eInvalidValue, nil
    end
    gCharPointer = gCharPointer + 1
  end
  return TkJson.errorCode.eOk, false
end

function isPlus()
  if gCharArray[gCharPointer] then
    local byteCode = string.byte(gCharArray[gCharPointer])
    return (byteCode >= string.byte('1') and byteCode <= string.byte('9'))
  else
    return false
  end
end

function isDigit()
  if gCharArray[gCharPointer] then
    local byteCode = string.byte(gCharArray[gCharPointer])
    return (byteCode >= string.byte('0') and byteCode <= string.byte('9'))
  else
    return false
  end
end

function parseNumber()
  local startPoint = gCharPointer
  if gCharArray[gCharPointer] == '-' then
    gCharPointer = gCharPointer + 1
  end
  if gCharArray[gCharPointer] == '0' then
    gCharPointer = gCharPointer + 1
  else 
    if not isPlus() then
      return TkJson.errorCode.eInvalidValue, nil
    end
    repeat
      gCharPointer = gCharPointer + 1
    until (not isDigit())
  end
  if gCharArray[gCharPointer] == '.' then
    gCharPointer = gCharPointer + 1
    if not isDigit() then
      return TkJson.errorCode.eInvalidValue, nil
    end
    repeat
      gCharPointer = gCharPointer + 1
    until (not isDigit())
  end
  if gCharArray[gCharPointer] == 'e' or 
    gCharArray[gCharPointer] == 'E' then
      gCharPointer = gCharPointer + 1
    if gCharArray[gCharPointer] == '+' or
      gCharArray[gCharPointer] == '-' then
        gCharPointer = gCharPointer + 1
    end
    if not isDigit() then
      return TkJson.errorCode.eInvalidValue, nil
    end
    repeat
      gCharPointer = gCharPointer + 1
    until (not isDigit())
  end

  local stopPoint = gCharPointer - 1
  local value = tonumber(table.concat(gCharArray, '', startPoint, stopPoint))
  if value == math.huge or value == -math.huge then
    return TkJson.errorCode.eNumberTooBig, nil
  else
    return TkJson.errorCode.eOk,  value
  end
end

function decodeUtf8()
  local hex = 0
  local ch = nil
  local bt = 0
  for i = 1, 4 do
    ch = gCharArray[gCharPointer]
    gCharPointer = gCharPointer + 1
    if ch == nil then
      return nil
    else
      bt = string.byte(ch)
      hex = hex << 4
      if bt >= string.byte('0') and bt <= string.byte('9') then
        hex = hex | (bt - string.byte('0'))
      elseif bt >= string.byte('A') and bt <= string.byte('F') then
        hex = hex | (bt - (string.byte('A') - 10))
      elseif bt >= string.byte('a') and bt <= string.byte('f') then
        hex = hex | (bt - (string.byte('a') - 10))
      else
        return nil
      end
    end
  end
  return hex
end

function encodeUtf8(hex)
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

function parseString()
  local value = ''

  gCharPointer = gCharPointer + 1
  while true do
    local ch = gCharArray[gCharPointer]
    gCharPointer = gCharPointer + 1
    if ch == nil then
      return TkJson.errorCode.eMissQuotationMark, nil
    elseif ch == '"' then
      return TkJson.errorCode.eOk, value
    elseif ch == '\\' then
      ch = gCharArray[gCharPointer]
      gCharPointer = gCharPointer + 1
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
          ch = gCharArray[gCharPointer]
          gCharPointer = gCharPointer + 1
          if ch ~= '\\' then
            return TkJson.errorCode.eInvalidUnicodeSurrogate, nil
          end
          ch = gCharArray[gCharPointer]
          gCharPointer = gCharPointer + 1
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

function parseArray()
  local result = TkJson.errorCode.eOk
  local value = {
    __length = 0
  }
  
  gCharPointer = gCharPointer + 1
  parseWhitespace()
  if gCharArray[gCharPointer] == ']' then
    gCharPointer = gCharPointer + 1
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
      if gCharArray[gCharPointer] == ',' then
        gCharPointer = gCharPointer + 1
        parseWhitespace()
      elseif gCharArray[gCharPointer] == ']' then
        gCharPointer = gCharPointer + 1
        return result, value
      else
        result = TkJson.errorCode.eMissCommaOrSquareBracket
        return result, nil
      end
    end
  end
end

function parseValue()
  local ch = gCharArray[gCharPointer]
  if ch == nil then
    return TkJson.errorCode.eExpectValue, nil
  elseif ch == 'n' then
    return parseNull()
  elseif ch == 't' then
    return parseTrue()
  elseif ch == 'f' then
    return parseFalse()
  elseif ch == '"' then
    return parseString()
  elseif ch == '[' then
    return parseArray()
  elseif ch == '{' then
    -- return parseObject()
  else
    return parseNumber()
  end
end

function TkJson.parse(jsonString)
  local result = TkJson.errorCode.eExpectValue
  local value = nil
  gCharArray = {}
  gCharPointer = 1

  for ch in string.gmatch(jsonString, utf8.charpattern) do
    --print(ch)
    table.insert(gCharArray, ch)
  end

  parseWhitespace()
  result, value = parseValue()
  if result == TkJson.errorCode.eOk then
    parseWhitespace()
    if gCharPointer <= #gCharArray then
      result = TkJson.errorCode.eRootNotSingular
      value = nil
    end
  end
  return result, value
end

return TkJson