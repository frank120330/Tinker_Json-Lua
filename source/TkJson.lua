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

TkJson.parseString = function()
  local resultString = ''

  TkJson.gCharPointer = TkJson.gCharPointer + 1
  while true do
    local ch = TkJson.gCharArray[TkJson.gCharPointer]
    TkJson.gCharPointer = TkJson.gCharPointer + 1
    if ch == nil then
      return TkJson.errorCode.eMissQuotationMark, nil
    elseif ch == '"' then
      return TkJson.errorCode.eOk, resultString
    elseif ch == '\\' then
      ch = TkJson.gCharArray[TkJson.gCharPointer]
      TkJson.gCharPointer = TkJson.gCharPointer + 1
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
        -- TODO
      else
        -- TODO
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
    -- return parseString()
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