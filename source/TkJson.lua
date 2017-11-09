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

TkJson._charArray = {}
TkJson._pointer = 1

-- Parser functions

TkJson.parseString = function()
  local resultString = ''

  TkJson._pointer = TkJson._pointer + 1
  while true do
    local ch = TkJson._charArray[TkJson._pointer]
    TkJson._pointer = TkJson._pointer + 1
    if ch == nil then
      return TkJson.errorCode.eMissQuotationMark, nil
    elseif ch == '"' then
      return TkJson.errorCode.eOk, resultString
    elseif ch == '\\' then
      ch = TkJson._charArray[TkJson._pointer]
      TkJson._pointer = TkJson._pointer + 1
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
        
    else
      if string.byte(ch) < 0x20 then
        return TkJson.errorCode.eInvalidStringChar, nil
      else
        resultString = resultString .. ch
      end
    end
  end
end

TkJson.parseNumber = function()
  local isPlus = function()
    if TkJson._charArray[TkJson._pointer] then
      local byteCode = string.byte(TkJson._charArray[TkJson._pointer])
      return (byteCode >= string.byte('1') and byteCode <= string.byte('9'))
    else
      return false
    end
  end

  local isDigit = function()
    if TkJson._charArray[TkJson._pointer] then
      local byteCode = string.byte(TkJson._charArray[TkJson._pointer])
      return (byteCode >= string.byte('0') and byteCode <= string.byte('9'))
    else
      return false
    end
  end

  local startPoint = TkJson._pointer
  if TkJson._charArray[TkJson._pointer] == '-' then
    TkJson._pointer = TkJson._pointer + 1
  end
  if TkJson._charArray[TkJson._pointer] == '0' then
    TkJson._pointer = TkJson._pointer + 1
  else 
    if not isPlus() then
      return TkJson.errorCode.eInvalidValue, nil
    end
    repeat
      TkJson._pointer = TkJson._pointer + 1
    until (not isDigit())
  end
  if TkJson._charArray[TkJson._pointer] == '.' then
    TkJson._pointer = TkJson._pointer + 1
    if not isDigit() then
      return TkJson.errorCode.eInvalidValue, nil
    end
    repeat
      TkJson._pointer = TkJson._pointer + 1
    until (not isDigit())
  end
  if TkJson._charArray[TkJson._pointer] == 'e' or 
    TkJson._charArray[TkJson._pointer] == 'E' then
      TkJson._pointer = TkJson._pointer + 1
    if TkJson._charArray[TkJson._pointer] == '+' or
      TkJson._charArray[TkJson._pointer] == '-' then
        TkJson._pointer = TkJson._pointer + 1
    end
    if not isDigit() then
      return TkJson.errorCode.eInvalidValue, nil
    end
    repeat
      TkJson._pointer = TkJson._pointer + 1
    until (not isDigit())
  end

  local stopPoint = TkJson._pointer - 1
  local numberValue = tonumber(table.concat(TkJson._charArray, '', startPoint, stopPoint))
  if numberValue == math.huge or numberValue == -math.huge then
    return TkJson.errorCode.eNumberTooBig, nil
  else
    return TkJson.errorCode.eOk,  numberValue
  end
end

TkJson.parseFalse = function()
  local falseString = {
    'f', 'a', 'l', 's', 'e'
  }
  for i = 1, 5 do
    if TkJson._charArray[TkJson._pointer] ~= falseString[i] then
      return TkJson.errorCode.eInvalidValue, nil
    end
    TkJson._pointer = TkJson._pointer + 1
  end
  return TkJson.errorCode.eOk, false
end

TkJson.parseTrue = function()
  local trueString = {
    't', 'r', 'u', 'e'
  }
  for i = 1, 4 do
    if TkJson._charArray[TkJson._pointer] ~= trueString[i] then
      return TkJson.errorCode.eInvalidValue, nil
    end
    TkJson._pointer = TkJson._pointer + 1
  end
  return TkJson.errorCode.eOk, true
end

TkJson.parseNull = function()
  local nullString = {
    'n', 'u', 'l', 'l'
  }
  for i = 1, 4 do
    if TkJson._charArray[TkJson._pointer] ~= nullString[i] then
      return TkJson.errorCode.eInvalidValue, nil
    end
    TkJson._pointer = TkJson._pointer + 1
  end
  return TkJson.errorCode.eOk, nil
end

TkJson.parseValue = function()
  local ch = TkJson._charArray[TkJson._pointer]
  if ch == nil then
    return TkJson.errorCode.eExpectValue, nil
  elseif ch == 'n' then
    return TkJson.parseNull()
  elseif ch == 't' then
    return TkJson.parseTrue()
  elseif ch == 'f' then
    return TkJson.parseFalse()
  elseif ch == '"' then
    return TkJson.parseString()
  elseif ch == '[' then
    -- return TkJson.parseArray()
  elseif ch == '{' then
    -- return TkJson.parseObject()
  else
    return TkJson.parseNumber()
  end
end

TkJson.parseWhitespace = function()
  while TkJson._charArray[TkJson._pointer] == ' ' or
    TkJson._charArray[TkJson._pointer] == '\t' or
    TkJson._charArray[TkJson._pointer] == '\n' or
    TkJson._charArray[TkJson._pointer] == '\r' do
    TkJson._pointer = TkJson._pointer + 1
  end
end

TkJson.parse = function(jsonString)
  local parseResult = TkJson.errorCode.eExpectValue
  local parseValue = nil
  TkJson._charArray = {}
  TkJson._pointer = 1

  for ch in string.gmatch(jsonString, utf8.charpattern) do
    --print(ch)
    table.insert(TkJson._charArray, ch)
  end

  TkJson.parseWhitespace()
  parseResult, parseValue = TkJson.parseValue()
  if parseResult == TkJson.errorCode.eOk then
    TkJson.parseWhitespace()
    if TkJson._pointer <= #TkJson._charArray then
      parseResult = TkJson.errorCode.eRootNotSingular
      parseValue = nil
    end
  end
  return parseResult, parseValue
end

return TkJson