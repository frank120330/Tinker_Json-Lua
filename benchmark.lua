--[[
  Project   TkJson-Lua
  Author    T1nKeR
  File      benchmark.lua
  Description
    The driver that runs the benchmark tasks.
--]]

local TkBench = require('source/TkBench')

local libraryArray = {
  '../bench/TkJson',
  '../bench/dkjson',
  -- '../bench/jfjson',
  '../bench/json'
}

local fileArray = {
  'test/canada.json',
  'test/citm_catalog.json',
  'test/twitter.json'
}

local RegisterLibrary = function()
  TkBench.Reset()

  local json_library = nil
  for key, value in ipairs(libraryArray) do
    TkBench.registerLibrary(value)
  end
end

local BenchmarkDecoder = function()
  for key, value in pairs(fileArray) do
    TkBench.testAllDecode(value)
  end
end

local BenchmarkEncoder = function()
  for key, value in pairs(fileArray) do
    TkBench.testAllEncode(value)
  end
end

local function MainApp()
  RegisterLibrary()
-- BenchmarkDecoder()
-- BenchmarkEncoder()
end

MainApp()
