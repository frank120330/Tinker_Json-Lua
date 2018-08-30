--[[
  Project   TkJson-Lua
  Author    T1nKeR
  File      TkDriver.lua
  Description
    A simple framework for unit tests.
    It is a auxiliary library over TkTest.
--]]

local TkJson = require('source/TkJson')
local TkTest = require('source/TkTest')

local TkDriver = {}

function TkDriver.TestError(error_code, row, column, json_string)
  local status, error_msg = pcall(TkJson.Decode, json_string)
  local expect_error_msg = string.format(
    '> Error: Line %d Column %d - %s', 
    row, column, error_code
  )
  TkTest.ExpectBoolean(false, status)
  TkTest.ExpectString(expect_error_msg, error_msg)
end

function TkDriver.TestDecode(expect, json)
  local value = TkJson.Decode(json)
  local test_type = type(expect)
  if test_type == 'function' then
    TkTest.ExpectNull(expect, value)
  elseif test_type == 'boolean' then
    TkTest.ExpectBoolean(expect, value)
  elseif test_type == 'number' then
    TkTest.ExpectNumber(expect, value)
  elseif test_type == 'string' then
    TkTest.ExpectString(expect, value)
  elseif test_type == 'table' then
    if expect.__length ~= nil then
      TkTest.ExpectArray(expect, value)
    else
      TkTest.ExpectObject(expect, value)
    end
  else
    error('> Error - Unrecognized Data Type!')
  end
end

function TkDriver.TestEncode(json)
  local value = TkJson.Decode(json)
  local text = TkJson.Encode(value)
  TkTest.ExpectString(json, text)
end

return TkDriver
