local TkTest = {}

TkTest.expectEqual = function(equality, expect, actual, format)
  if not equality then
    local errorMsg = string.format(
      '> Test Failure - Expect: ' .. format .. ', Actual: ' .. format, 
      expect, actual
    )
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

return TkTest
