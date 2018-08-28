local TkTest = {}

function TkTest.ExpectEqual(equality, expect, actual, format)
  if not equality then
    local template = string.format(
      '> Test Failure - Expect: %s, Actual: %s', 
      format, format
    )
    local error_msg = string.format(template, expect, actual)
    error(error_msg)
  end
end

function TkTest.ExpectNull(expect, actual)
  local equality = (expect == actual)
  TkTest.ExpectEqual(equality, 'null', actual, '%s')
end

function TkTest.ExpectBoolean(expect, actual)
  local equality = (expect == actual)
  TkTest.ExpectEqual(equality, expect, actual, '%s')
end

function TkTest.ExpectInt(expect, actual)
  local equality = (expect == actual)
  TkTest.ExpectEqual(equality, expect, actual, '%d')
end

function TkTest.ExpectNumber(expect, actual)
  local equality = (expect == actual)
  TkTest.ExpectEqual(equality, expect, actual, '%f')
end

function TkTest.ExpectString(expect, actual)
  local equality = (expect == actual)
  TkTest.ExpectEqual(equality, expect, actual, '%s')
end
 
function TkTest.ExpectArray(expect, actual)
  local equality = (expect.__length == actual.__length)
  TkTest.ExpectEqual(equality, expect.__length, actual.__length, '%d')

  for i = 1, expect.__length do
    local expect_value = expect[i]
    local actual_value = actual[i]
    if type(expect_value) == 'function' then
      TkTest.ExpectNull(expect_value, actual_value)
    elseif type(expect_value) == 'boolean' then
      TkTest.ExpectBoolean(expect_value, actual_value)
    elseif type(expect_value) == 'number' then
      TkTest.ExpectNumber(expect_value, actual_value)
    elseif type(expect_value) == 'string' then
      TkTest.ExpectString(expect_value, actual_value)
    elseif type(expect_value) == 'table' then
      if expect_value.__length ~= nil then
        TkTest.ExpectArray(expect_value, actual_value)
      else
        TkTest.ExpectObject(expect_value, actual_value)
      end
    else
      error('> Test Failure - Unrecognized Data Type!')
    end
  end
end

function TkTest.ExpectObject(expect, actual)
  for key, value in pairs(expect) do
    local another = actual[key]
    if type(value) == 'function' then
      TkTest.ExpectNull(value, another)
    elseif type(value) == 'boolean' then
      TkTest.ExpectBoolean(value, another)
    elseif type(value) == 'number' then
      TkTest.ExpectNumber(value, another)
    elseif type(value) == 'string' then
      TkTest.ExpectString(value, another)
    elseif type(value) == 'table' then
      if value.__length ~= nil then
        TkTest.ExpectArray(value, another)
      else
        TkTest.ExpectObject(value, another)
      end
    else
      error('> Test Failure - Unrecognized Data Type!')
    end
  end
end

return TkTest
