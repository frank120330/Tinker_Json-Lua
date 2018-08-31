--[[
  Project   TkJson-Lua
  Author    T1nKeR
  File      TkJson.lua
  Description
    A simple JSON library that decodes a JSON string or encodes a Lua value.
--]]

local error, setmetatable = error, setmetatable
local string_byte, string_format, string_find = 
  string.byte, string.format, string.find

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
local DecodeNumber
local DecodeUnicode
local DecodeString

function DecodeError(error_code)
  local row_number = 1
  local col_number = 1

  for i = 1, g_pointer - 1 do
    if string_byte(g_json_string, i) == 10 then
      row_number = row_number + 1
      col_number = 1
    else
      col_number = col_number + 1
    end
  end

  local error_msg = string_format(
    '> Error: Line %d Column %d - %s', 
    row_number, col_number, error_code
  )
  error(error_msg, 0)
end

function DecodeNull()
  valid, g_pointer = string_find(g_json_string, '^null', g_pointer)
  if not valid then
    DecodeError(TkJson.ErrorCode.InvalidValue)
  end
  g_pointer = g_pointer + 1
  return TkJson.null
end

function DecodeTrue()
  valid, g_pointer = string_find(g_json_string, '^true', g_pointer)
  if not valid then
    DecodeError(TkJson.ErrorCode.InvalidValue)
  end
  g_pointer = g_pointer + 1
  return true
end

function DecodeFalse()
  valid, g_pointer = string_find(g_json_string, '^false', g_pointer)
  if not valid then
    DecodeError(TkJson.ErrorCode.InvalidValue)
  end
  g_pointer = g_pointer + 1
  return false
end

local value_char = {
  [110] = DecodeNull, [116] = DecodeTrue, [102] = DecodeFalse,
  [34] = DecodeString, [91] = DecodeArray, [123] = decodeObject, 
  [45] = DecodeNumber, [48] = DecodeNumber, [49] = DecodeNumber,
  [50] = DecodeNumber, [51] = DecodeNumber, [52] = DecodeNumber,
  [53] = DecodeNumber, [54] = DecodeNumber, [55] = DecodeNumber,
  [56] = DecodeNumber, [57] = DecodeNumber
}
function DecodeValue()
  local next_char = string_byte(g_json_string, g_pointer)
  local decode_function = value_char[next_char]
  if decode_function then
    return decode_function()
  else
    if next_char then
      DecodeError(TkJson.ErrorCode.InvalidValue)
    else
      DecodeError(TkJson.ErrorCode.ExpectValue)
    end
  end
end

function Decode(json_string)
  g_json_string = json_string
  g_pointer = 1

  _, g_pointer = string_find(g_json_string, '^[ \n\r\t]*', g_pointer)
  g_pointer = g_pointer + 1

  local value = DecodeValue()

  _, g_pointer = string_find(g_json_string, '^[ \n\r\t]*', g_pointer)
  if g_pointer ~= #json_string then
    DecodeError(TkJson.ErrorCode.RootNotSingular)
  end

  return value
end

TkJson.Decode = Decode

return TkJson
