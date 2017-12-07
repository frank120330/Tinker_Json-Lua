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
  TkBench.resetBench()
  for key, value in ipairs(libraryArray) do
    TkBench.registerLibrary(value)
  end
end

local BenchmarkDecoder = function()
  for key, value in pairs(fileArray) do
    TkBench.testAllDecode(value)
  end
end

RegisterLibrary()
BenchmarkDecoder()
