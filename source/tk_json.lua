local TkJson = {}

TkJson.errorCode = {
  eOk = 0,
  eNotWhitespace = 1,
  eExpectValue = 2,
  eInvalidValue = 3,
  eRootNotSingular = 4
}

TkJson.typeCode = {
  eEmpty = 0,
  eWhitespace = 1,
  eValue = 2,
  eNull = 3,
  eTrue = 4,
  eFalse = 5,
  eString = 6,
  eArray = 7,
  eObject = 8
}

TkJson._currentType = TkJson.typeCode.eValue
TkJson._value = nil

local nullIndex = 1
TkJson.parseNull = function(ch)
  if (nullIndex == 1 and ch == 'n') or
    (nullIndex == 2 and ch == 'u') or
    (nullIndex == 3 and ch == 'l') or
    (nullIndex == 4 and ch == 'l') then
    nullIndex = nullIndex + 1
    return TkJson.errorCode.eOk, nil
  else
    return TkJson.errorCode.eInvalidValue, nil
  end
end

TkJson.parseWhitespace = function(ch)
  if ch == ' ' or ch == '\t' or ch == '\n' or ch == '\r' then
    return TkJson.errorCode.eOk
  else
    return TkJson.errorCode.eOk
  end
end

TkJson.parseValue = function(ch)
  local parseResult = eOk
  local parseValue = nil
  if TkJson._currentType == TkJson.typeCode.eValue then
    if ch == 'n' then
      TkJson._currentType = TkJson.typeCode.eNull
      parseResult, parseValue = TkJson.parseNull(ch)
    -- elseif ch == 't' then
    --   TkJson._currentType = TkJson.typeCode.eTrue
    --   parseResult, parseValue = TkJson.parseTrue(ch)
    -- elseif ch == 'f' then
    --   TkJson._currentType = TkJson.typeCode.eFalse
    --   parseResult, parseValue = TkJson.parseFalse(ch)
    -- elseif ch == '"' then
    --   TkJson._currentType = TkJson.typeCode.eString
    --   parseResult, parseValue = TkJson.parseString(ch)
    -- elseif ch == '[' then
    --   TkJson._currentType = TkJson.typeCode.eArray
    --   parseResult, parseValue = TkJson.parseArray(ch)
    -- elseif ch == '{' then
    --   TkJson._currentType = TkJson.typeCode.eObject
    --   parseResult, parseValue = TkJson.parseObject(ch)
    -- else
    --   TkJson._currentType = TkJson.typeCode.eNumber
    --   parseResult, parseValue = TkJson.parseNumber(ch)
    end
  elseif TkJson._currentType == TkJson.typeCode.eNull then
    parseResult, parseValue = TkJson.parseNull(ch)
  else
    parseResult, parseValue = TkJson.errorCode.eInvalidValue, nil
  end
  return parseResult, parseValue
end 

TkJson.parse = function(jsonString)
  local parseResult = TkJson.errorCode.eExpectValue
  local parseValue = nil
  for ch in string.gmatch(jsonString, utf8.charpattern) do
    parseResult, parseValue = TkJson.parseValue(ch)
    if parseResult ~= TkJson.errorCode.eOk then
      break
    end
  end
  return parseResult, parseValue
end

return TkJson
