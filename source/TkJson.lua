--[[
  Author    T1nKeR
  Project   TkJson-Lua
--]]

local TkJson = {}

TkJson.ErrorCode = {
  Ok = 'Decode successfully',
  ExpectValue = 'Expect a value',
  InvalidValue = 'Invalid value',
  RootNotSingular = 'Root not singular',
  NumberTooBig = 'Number too big',
  MissQuotationMark = 'Miss quotation mark',
  InvalidStringEscape = 'Invalid string escape',
  InvalidStringChar = 'Invalid string char',
  InvalidUnicodeHex = 'Invalid unicode hex',
  InvalidUnicodeSurrogate = 'Invalid unicode surrogate',
  MissCommaOrSquareBracket = 'Miss comma or square bracket',
  MissKey = 'Miss key in key-value pair',
  MissColon = 'Miss colon',
  MissCommaOrCurlyBracket = 'Miss comma or curly bracket'
}

TkJson.null = {}
setmetatable(TkJson.null, {
  __newindex = function(dict, key, value)
    error('> Error: TkJson.null is immutable!')
  end,
  __tostring = function()
    return 'null'
  end
})

local g_iterator = nil
local g_next_char = nil
local g_pointer = nil
local g_json_string = nil

local Decode
local DecodeError
local DecodeWhitespace
local DecodeValue
local DecodeNull
local DecodeTrue
local DecodeFalse

function DecodeError(error_code)
  local row_number = 1
  local col_number = 1

  local iterator = string.gmatch(g_json_string, '.')
  local next_char = iterator()
  local pointer = 1

  while pointer < g_pointer do
    pointer = pointer + 1
    next_char = iterator()
    if next_char == '\n' then
      row_number = row_number + 1
      col_number = 1
    else
      col_number = col_number + 1
    end
  end

  local error_msg = string.format(
    '> Error: Line %d Column %d - %s', 
    row_number, col_number, error_code
  )
  error(error_msg, 0)
end

local whitespace_char = {
  [' '] = true, ['\t'] = true,
  ['\n'] = true, ['\r'] = true
}
function DecodeWhitespace()
  while whitespace_char[g_next_char] do
    g_pointer = g_pointer + 1
    g_next_char = g_iterator()
  end
end

local null_char = {
  'n', 'u', 'l', 'l'
}
function DecodeNull()
  for i = 1, 4 do
    if g_next_char ~= null_char[i] then
      DecodeError(TkJson.ErrorCode.InvalidValue)
    end
    g_pointer = g_pointer + 1
    g_next_char = g_iterator()
  end
  return TkJson.null
end

local true_char = {
  't', 'r', 'u', 'e'
}
function DecodeTrue()
  for i = 1, 4 do
    if g_next_char ~= true_char[i] then
      DecodeError(TkJson.ErrorCode.InvalidValue)
    end
    g_pointer = g_pointer + 1
    g_next_char = g_iterator()
  end
  return true
end

local false_char = {
  'f', 'a', 'l', 's', 'e'
}
function DecodeFalse()
  for i = 1, 5 do
    if g_next_char ~= false_char[i] then
      DecodeError(TkJson.ErrorCode.InvalidValue)
    end
    g_pointer = g_pointer + 1
    g_next_char = g_iterator()
  end
  return false
end

local number_char = {
  ['0'] = true, ['1'] = true, ['2'] = true, ['3'] = true, ['4'] = true, 
  ['5'] = true, ['6'] = true, ['7'] = true, ['8'] = true, ['9'] = true,
  ['+'] = true, ['-'] = true, ['.'] = true, ['e'] = true, ['E'] = true
}
decodeNumber = function()
  local start_point = g_pointer
  while numberChar[gNextChar] do
    gPointer = gPointer + 1
    gNextChar = gIterator()
  end

  local stopPoint = gPointer - 1
  local value = tonumber(string.sub(gString, startPoint, stopPoint))
  if value == nil then
    decodeError(TkJson.errorCode.eInvalidValue)
  elseif value == math.huge or value == -math.huge then
    decodeError(TkJson.errorCode.eNumberTooBig)
  else
    return value
  end
end

local value_char = {
  ['n'] = DecodeNull, ['t'] = DecodeTrue, ['f'] = DecodeFalse,
  -- ['"'] = decodeString, ['['] = decodeArray, ['{'] = decodeObject, 
  -- ['-'] = decodeNumber, ['0'] = decodeNumber, ['1'] = decodeNumber,
  -- ['2'] = decodeNumber, ['3'] = decodeNumber, ['4'] = decodeNumber,
  -- ['5'] = decodeNumber, ['6'] = decodeNumber, ['7'] = decodeNumber,
  -- ['8'] = decodeNumber, ['9'] = decodeNumber
}
function DecodeValue()
  if value_char[g_next_char] then
    local decode_function = value_char[g_next_char]
    return decode_function()
  else
    if g_next_char then
      DecodeError(TkJson.ErrorCode.InvalidValue)
    else
      DecodeError(TkJson.ErrorCode.ExpectValue)
    end
  end
end

function Decode(json_string)
  local value = nil
  
  g_json_string = json_string
  g_iterator = string.gmatch(g_json_string, '.')
  g_next_char = g_iterator()
  g_pointer = 1

  DecodeWhitespace()
  value = DecodeValue()
  DecodeWhitespace()

  if g_next_char ~= nil then
    DecodeError(TkJson.ErrorCode.RootNotSingular)
  end
  return value
end

TkJson.Decode = Decode

return TkJson