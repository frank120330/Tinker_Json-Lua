local TkTest = {}

TkTest.expectEqualInt = function(expect, actual)
  if expect ~= actual then
    local errorMsg = string.format(
      '> Test Failure - Type: Integer, Expect: %d, Actual: %d', 
      expect, actual
    )
    error(errorMsg)
  end
end

TkTest.expectEqualNil = function(actual)
  if actual ~= nil then
    local errorMsg = string.format(
      '> Test Failure - Type: Nil, Expect: nil, Actual: %s', type(actual)
    )
    error(errorMsg)
  end
end

return TkTest
