local TkBench = {}

TkBench.parserName = nil
TkBench.parserFunction = nil

TkBench.registerParser = function(parserName)
  local parserLibrary = require(parserName)
  TkBench.parserName = parserName
  TkBench.parserFunction = parserLibrary.decode
end

TkBench.benchParser = function(filename)
  local jsonFile = assert(io.open(filename, 'r'))
  local jsonString = jsonFile:read('a')

  local totalTime = 0.0
  local totalCount = 10
  for i = 1, totalCount do
    local startClock = os.clock()
    local value = TkBench.parserFunction(jsonString)
    local stopClock = os.clock()
    totalTime = totalTime + (stopClock - startClock)
  end 
  totalTime = totalTime / totalCount
  print(
    string.format(
      "> Pressure Test - JSON Parser: %s, Filename: %s, Elapsed Time: %fs", 
      TkBench.parserName, filename, totalTime
    )
  )
end