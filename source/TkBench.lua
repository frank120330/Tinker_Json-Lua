--[[
  Project   TkJson-Lua
  Author    T1nKeR
  File      TkBench.lua
  Decription
    A benchmark library.
--]]

local TkBench = {}

TkBench.LibraryQueue = {}

function TkBench.Reset()
  TkBench.LibraryQueue = {}
end

function TkBench.RegisterLibrary(library_name, decoder, encoder)
  local library = {}
  library.name = library_name
  library.decode = decoder
  library.encode = encoder
  table.insert(TkBench.LibraryQueue, library)
end

function TkBench.TestDecode(library, filename)
  local json_file = assert(io.open(filename, 'r'))
  local json_string = json_file:read('a')

  local test_time = 0.0
  local test_count = 10
  for i = 1, test_count do
    local start_clock = os.clock()
    local value = library.decode(json_string)
    local stop_clock = os.clock()
    test_time = test_time + (stop_clock - start_clock)
  end 
  test_time = test_time / test_count
  print(
    string.format(
      "> Pressure Test - JSON Decoder: %s, Filename: %s, Elapsed Time: %fs", 
      library.name, filename, totalTime
    )
  )

  return test_time
end

function TkBench.TestEncode(library, filename)
  local json_file = assert(io.open(filename, 'r'))
  local json_string = json_file:read('a')
  local json_value = library.decode(json_string)

  local test_time = 0.0
  local test_count = 10
  for i = 1, test_count do
    local start_clock = os.clock()
    local value = library.encode(json_value)
    local stop_clock = os.clock()
    test_time = test_time + (stop_clock - start_clock)
  end 
  test_time = test_time / test_count
  print(
    string.format(
      "> Pressure Test - JSON Encoder: %s, Filename: %s, Elapsed Time: %fs", 
      library.name, filename, totalTime
    )
  )

  return test_time
end

function TkBench.DecodeBenchmark(filename)
  for key, library in ipairs(TkBench.LibraryQueue) do
    TkBench.TestDecode(library, filename)
  end
  print('--------------------------------------------------------------')
end

function TkBench.EncodeBenchmark(filename)
  for key, library in ipairs(TkBench.LibraryQueue) do
    TkBench.TestEncode(library, filename)
  end
  print('--------------------------------------------------------------')
end

return TkBench
