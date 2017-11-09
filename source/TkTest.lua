local TkTest = {}

TkTest.expectEqual = function(equality, expect, actual, format)
  if not equality then
    local template = string.format('> Test Failure - Expect: %s, Actual: %s', format, format)
    local errorMsg = string.format(template, expect, actual)
    error(errorMsg)
  end
end

TkTest.expectEqualInt = function(expect, actual)
  local equality = (expect == actual)
  TkTest.expectEqual(equality, expect, actual, '%d')
end

TkTest.expectEqualLiteral = function(expect, actual)
  local equality = (expect == actual)
  TkTest.expectEqual(equality, nil, actual, '%s')
end

TkTest.expectEqualNumber = function(expect, actual)
  local equality = (expect == actual)
  TkTest.expectEqual(equality, expect, actual, '%f')
end

TkTest.expectEqualString = function(expect, actual)
  local equality = (expect == actual)
  TkTest.expectEqual(equality, expect, actual, '%s')
end

local function isArray(t)
  if type(t) ~= 'table' then
    return false
  end
  
  local length = #t
  for key, value in pairs(t) do
    if type(key) ~= 'number' then
      return false
    end
    local index = math.tointeger(key)
    if index == nil or index <= 0 or index > length then
      return false
    end
  end
  
  return true
end
 
TkTest.expectEqualTable = function(expect, actual)
  for key, value1 in pairs(expect) do
    local value2 = actual[key]
    if type(value1) == 'nil' or type(value1) == 'boolean' then
      TkTest.expectEqualLiteral(value1, value2)
    elseif type(value1) == 'number' then
      TkTest.expectEqualNumber(value1, value2)
    elseif type(value1) == 'string' then
      TkTest.expectEqualString(value1, value2)
    elseif type(value1) == 'table' then
      TkTest.expectEqualTable(value1, value2)
    else
      error('> Unrecognized Data Type!')
    end
  end
end

return TkTest
