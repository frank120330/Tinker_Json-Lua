local TkBench = {}

TkBench.libArray = {}

TkBench.resetBench = function()
  TkBench.libArray = {}
end

TkBench.registerLibrary = function(libName)
  local libObject = {}
  libObject.name = libName
  libObject.library = require(libObject.name)
  if libObject.library then
    libObject.decoder = libObject.library.decode
    libObject.encoder = libObject.library.encode
    table.insert(TkBench.libArray, libObject)
  else
    print('Load library `' + libName + '` failed!')
  end
end

TkBench.testDecode = function(library, filename)
  local jsonFile = assert(io.open(filename, 'r'))
  local jsonString = jsonFile:read('a')

  local totalTime = 0.0
  local totalCount = 10
  for i = 1, totalCount do
    local startClock = os.clock()
    local value = library.decoder(jsonString)
    local stopClock = os.clock()
    totalTime = totalTime + (stopClock - startClock)
  end 
  totalTime = totalTime / totalCount
  print(
    string.format(
      "> Pressure Test - JSON Parser: %s, Filename: %s, Elapsed Time: %fs", 
      library.name, filename, totalTime
    )
  )

  return totalTime
end


TkBench.testAllDecode = function(filename)
  for key, library in pairs(TkBench.libArray) do
    TkBench.testDecode(library, filename)
  end
  print('--------------------------------------------------------------')
end

return TkBench