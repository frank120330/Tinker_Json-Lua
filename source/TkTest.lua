local TkTest = {}

TkTest.expectEqual = function(equality, expect, actual, format)
  -- print(expect, actual)
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
  TkTest.expectEqual(equality, expect, actual, '%s')
end

TkTest.expectEqualNumber = function(expect, actual)
  local equality = (expect == actual)
  TkTest.expectEqual(equality, expect, actual, '%f')
end

TkTest.expectEqualString = function(expect, actual)
  local equality = (expect == actual)
  TkTest.expectEqual(equality, expect, actual, '%s')
end
 
TkTest.expectEqualArray = function(expect, actual)
  local equality = (expect.__length == actual.__length)
  TkTest.expectEqual(equality, expect.__length, actual.__length, '%d')

  for i = 1, expect.__length do
    local expectValue = expect[i]
    local actualValue = actual[i]
    if type(expectValue) == 'nil' or type(expectValue) == 'boolean' then
      TkTest.expectEqualLiteral(expectValue, actualValue)
    elseif type(expectValue) == 'number' then
      TkTest.expectEqualNumber(expectValue, actualValue)
    elseif type(expectValue) == 'string' then
      TkTest.expectEqualString(expectValue, actualValue)
    elseif type(expectValue) == 'table' then
      if expectValue.__length ~= nil then
        TkTest.expectEqualArray(expectValue, actualValue)
      else
        TkTest.expectEqualObject(expectValue, actualValue)
      end
    else
      error('> Unrecognized Data Type!')
    end
  end
end

TkTest.expectEqualObject = function(expect, actual)
  for key, value in pairs(expect) do
    local another = actual[key]
    if type(value) == 'nil' or type(value) == 'boolean' then
      TkTest.expectEqualLiteral(value, another)
    elseif type(value) == 'number' then
      TkTest.expectEqualNumber(value, another)
    elseif type(value) == 'string' then
      TkTest.expectEqualString(value, another)
    elseif type(value) == 'table' then
      if value.__length ~= nil then
        TkTest.expectEqualArray(value, another)
      else
        TkTest.expectEqualObject(value, another)
      end
    else
      error('> Unrecognized Data Type!')
    end
  end
end

return TkTest
