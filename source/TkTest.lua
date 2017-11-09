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

return TkTest
