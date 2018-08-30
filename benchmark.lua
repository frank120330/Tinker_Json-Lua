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
  -- Register 'TkJson'
  json_library = require('source/TkJson')
  TkBench.RegisterLibrary('TkJson', json_library.Decode, json_library.Encode)
  -- Register 'dkjson'
  json_library = require('bench/dkjson');
  TkBench.RegisterLibrary('dkjson', json_library.decode, json_library.decode)
  -- Register 'json.lua'
  json_library = require('bench/json')
  TkBench.RegisterLibrary('json.lua', json_library.decode, json_library.decode)
  -- Register 'jfjson'
  -- jfjson takes more than 1 minute to parse the given json text.
  --json_library = require('bench/jfjson')
  --function json_library.decode(json_string)
  --  return json_library:decode(json_string)
  --end
  --function json_library.encode(json_string)
  --  return json_library:encode(json_string)
  --end
  --TkBench.RegisterLibrary('jfjson', json_library.decode, json_library.encode)
  -- Register 'json4lua'
  -- json4lua takes more than 1 minute to parse the given json text.
  --json_library = require('bench/json4lua')
  --TkBench.RegisterLibrary('json4lua', json_library.decode, json_library.encode)
  
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
