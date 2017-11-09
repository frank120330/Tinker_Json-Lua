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
  eInvalidUnicodeSurrogate = 10
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

-- Variables used by multiple parser functions

local gCharArray = {}
local gCharPointer = 1

-- Parser functions

local decodeUtf8 = function()
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

local encodeUtf8 = function(hex)
  local str = nil
  if hex <= 0x7F then
    str = string.char(hex & 0xFF)
  elseif hex <= 0x7FF then
    str = string.char(
      (0xC0 | ((hex >> 6) & 0xFF)), 
      (0x80 | (hex & 0x3F))
    )
  elseif hex <= 0xFFFF then
    str = string.char(
      (0xE0 | ((hex >> 12) & 0xFF)),
      (0x80 | ((hex >> 6) & 0x3F)),
      (0x80 | (hex & 0x3F))
    )
  else
    str = string.char(
      (0xF0 | ((hex >> 18) & 0xFF)),
      (0x80 | ((hex >> 12) & 0x3F)),
      (0x80 | ((hex >> 6) & 0x3F)),
      (0x80 | (hex & 0x3F))
    )
  end
  return str
end

local parseString = function()
  local resultString = ''

  gCharPointer = gCharPointer + 1
  while true do
    local ch = gCharArray[gCharPointer]
    gCharPointer = gCharPointer + 1
    if ch == nil then
      return TkJson.errorCode.eMissQuotationMark, nil
    elseif ch == '"' then
      return TkJson.errorCode.eOk, resultString
    elseif ch == '\\' then
      ch = gCharArray[gCharPointer]
      gCharPointer = gCharPointer + 1
      if ch == '\"' then
        resultString = resultString .. '\"'
      elseif ch == '\\' then
        resultString = resultString .. '\\'
      elseif ch == '/' then
        resultString = resultString .. '/'
      elseif ch == 'b' then
        resultString = resultString .. '\b'
      elseif ch == 'f' then
        resultString = resultString .. '\f'
      elseif ch == 'n' then
        resultString = resultString .. '\n'
      elseif ch == 'r' then
        resultString = resultString .. '\r'
      elseif ch == 't' then
        resultString = resultString .. '\t'
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
        resultString = resultString .. encodeUtf8(hex1)
      else
        return TkJson.errorCode.eInvalidStringEscape, nil
      end
    else
      if string.byte(ch) < 0x20 then
        return TkJson.errorCode.eInvalidStringChar, nil
      else
        resultString = resultString .. ch
      end
    end
  end
end

local isPlus = function()
  if gCharArray[gCharPointer] then
    local byteCode = string.byte(gCharArray[gCharPointer])
    return (byteCode >= string.byte('1') and byteCode <= string.byte('9'))
  else
    return false
  end
end

local isDigit = function()
  if gCharArray[gCharPointer] then
    local byteCode = string.byte(gCharArray[gCharPointer])
    return (byteCode >= string.byte('0') and byteCode <= string.byte('9'))
  else
    return false
  end
end

local parseNumber = function()
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
  local numberValue = tonumber(table.concat(gCharArray, '', startPoint, stopPoint))
  if numberValue == math.huge or numberValue == -math.huge then
    return TkJson.errorCode.eNumberTooBig, nil
  else
    return TkJson.errorCode.eOk,  numberValue
  end
end

local parseFalse = function()
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

local parseTrue = function()
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

local parseNull = function()
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

local parseValue = function()
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
    -- return parseArray()
  elseif ch == '{' then
    -- return parseObject()
  else
    return parseNumber()
  end
end

local parseWhitespace = function()
  while gCharArray[gCharPointer] == ' ' or
    gCharArray[gCharPointer] == '\t' or
    gCharArray[gCharPointer] == '\n' or
    gCharArray[gCharPointer] == '\r' do
    gCharPointer = gCharPointer + 1
  end
end

TkJson.parse = function(jsonString)
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