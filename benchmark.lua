--[[
  Project   TkJson-Lua
  Author    T1nKeR
  File      benchmark.lua
  Description
    The driver that runs the benchmark tasks.
--]]

local TkBench = require('source/TkBench')

local function MainApp()
  TkBench.Reset()

  local json_library = nil
  -- Register 'dkjson'
  json_library = require('bench/dkjson');
  TkBench.RegisterLibrary('dkjson', json_library.decode, json_library.decode)
  -- Register 'TkJson'
  json_library = require('source/TkJson')
  TkBench.RegisterLibrary('TkJson', json_library.Decode, json_library.Encode)
  
  local file_list = {
    'test/canada.json',
    'test/citm_catalog.json',
    'test/twitter.json'
  }
  for key, value in pairs(file_list) do
    TkBench.DecodeBenchmark(value)
  end
  -- for key, value in pairs(fileArray) do
  --   TkBench.EncodeBenchmark(value)
  -- end
end

MainApp()
