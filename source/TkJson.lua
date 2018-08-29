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
local DecodeNumber
local DecodeUnicode
local DecodeString

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
function DecodeNumber()
  local start_point = g_pointer
  while number_char[g_next_char] do
    g_pointer = g_pointer + 1
    g_next_char = g_iterator()
  end

  local stop_point = g_pointer - 1
  local value = tonumber(string.sub(g_json_string, start_point, stop_point))
  if value == nil then
    DecodeError(TkJson.ErrorCode.InvalidValue)
  elseif value == math.huge or value == -math.huge then
    DecodeError(TkJson.ErrorCode.NumberTooBig)
  else
    return value
  end
end

function DecodeUnicode(utf8_string)
  local hex1 = tonumber(string.sub(utf8_string, 3, 6), 16)
  local hex2 = tonumber(string.sub(utf8_string, 9, 12), 16)
  if hex2 then
    hex1 = (((hex1 - 0xD800) << 10) | (hex2 - 0xDC00)) + 0x10000
  end

  if hex1 <= 0x7F then
    return string.char(hex1 & 0xFF)
  elseif hex1 <= 0x7FF then
    return string.char(
      (0xC0 | ((hex1 >> 6) & 0xFF)), 
      (0x80 | (hex1 & 0x3F))
    )
  elseif hex1 <= 0xFFFF then
    return string.char(
      (0xE0 | ((hex1 >> 12) & 0xFF)),
      (0x80 | ((hex1 >> 6) & 0x3F)),
      (0x80 | (hex1 & 0x3F))
    )
  else
    return string.char(
      (0xF0 | ((hex1 >> 18) & 0xFF)),
      (0x80 | ((hex1 >> 12) & 0x3F)),
      (0x80 | ((hex1 >> 6) & 0x3F)),
      (0x80 | (hex1 & 0x3F))
    )
  end
end

local escape_char = {
  ['"'] = true, ['\\'] = true, ['/'] = true,
  ['b'] = true, ['f'] = true, ['n'] = true,
  ['r'] = true, ['t'] = true
}
local escape_value = {
  ['\\\"'] = '\"', ['\\\\'] = '\\', ['\\/'] = '/',
  ['\\b'] = '\b', ['\\f'] = '\f', ['\\n'] = '\n',
  ['\\r'] = '\r', ['\\t'] = '\t'
}
function DecodeString()
  local value = ''
  local start_point = g_pointer + 1
  local stop_point = g_pointer + 1
  local has_surrogate = false
  local has_unicode = false
  local has_escape = false

  while true do
    g_pointer = g_pointer + 1
    g_next_char = g_iterator()
    if g_next_char == '"' then
      stop_point = g_pointer - 1
      value = string.sub(g_json_string, start_point, stop_point)
      if string.find(value, '[\x01-\x1F]') then
        DecodeError(TkJson.ErrorCode.InvalidStringChar)
      end
      if has_surrogate then
        value = string.gsub(value, '\\u[dD][89AaBb]..\\u....', DecodeUnicode)
      end
      if has_unicode then
        value = string.gsub(value, '\\u....', DecodeUnicode)
      end
      if has_escape then
        value = string.gsub(value, '\\.', escape_value)
      end
      g_pointer = g_pointer + 1
      g_next_char = g_iterator()
      return value
    elseif g_next_char == '\\' then
      g_pointer = g_pointer + 1
      g_next_char = g_iterator()

      if g_next_char == 'u' then
        local hex_string = string.sub(g_json_string, g_pointer + 1, g_pointer + 4)
        if not string.find(hex_string, '%x%x%x%x') then
          DecodeError(TkJson.ErrorCode.InvalidUnicodeHex)
        end
        if string.find(hex_string, '^[Dd][89AaBb]') then
          has_surrogate = true
          for i = 1, 10 do
            g_pointer = g_pointer + 1
            g_next_char = g_iterator()
          end
        else
          has_unicode = true
          for i = 1, 4 do
            g_pointer = g_pointer + 1
            g_next_char = g_iterator()
          end
        end
      else
        if not escape_char[g_next_char] then
          DecodeError(TkJson.ErrorCode.InvalidStringEscape)
        else
          has_escape = true
        end
      end
    else
      if g_next_char == nil then
        DecodeError(TkJson.ErrorCode.MissQuotationMark)
      end
    end
  end
end

DecodeArray = function()
  local value = {
    __length = 0
  }
  local length = 0
  
  g_pointer = g_pointer + 1
  g_next_char = g_iterator()
  DecodeWhitespace()
  if g_next_char == ']' then
    g_pointer = g_pointer + 1
    g_next_char = g_iterator()
    return value
  end
  while true do
    local element = nil
    element = DecodeValue()
    length = length + 1
    value[length] = element
    DecodeWhitespace()
    if g_next_char == ',' then
      g_pointer = g_pointer + 1
      g_next_char = g_iterator()
      DecodeWhitespace()
    elseif g_next_char == ']' then
      value.__length = length
      g_pointer = g_pointer + 1
      g_next_char = g_iterator()
      return value
    else
      DecodeError(TkJson.ErrorCode.MissCommaOrSquareBracket)
    end
  end
end

decodeObject = function()
  local value = {}

  g_pointer = g_pointer + 1
  g_next_char = g_iterator()
  DecodeWhitespace()
  if g_next_char == '}' then
    g_pointer = g_pointer + 1
    g_next_char = g_iterator()
    return value
  end
  while true do
    local key = nil
    local element = nil

    if g_next_char ~= '"' then
      DecodeError(TkJson.ErrorCode.MissKey)
    end
    key = DecodeString()
    DecodeWhitespace()
    if g_next_char ~= ':' then
      DecodeError(TkJson.ErrorCode.MissColon)
    end
    g_pointer = g_pointer + 1
    g_next_char = g_iterator()
    DecodeWhitespace()
    element = DecodeValue()
    value[key] = element
    DecodeWhitespace()
    if g_next_char == ',' then
      g_pointer = g_pointer + 1
      g_next_char = g_iterator()
      DecodeWhitespace()
    elseif g_next_char == '}' then
      g_pointer = g_pointer + 1
      g_next_char = g_iterator()
      return value
    else
      DecodeError(TkJson.ErrorCode.MissCommaOrCurlyBracket)
    end
  end
end

local value_char = {
  ['n'] = DecodeNull, ['t'] = DecodeTrue, ['f'] = DecodeFalse,
  ['"'] = DecodeString, ['['] = DecodeArray, ['{'] = decodeObject, 
  ['-'] = DecodeNumber, ['0'] = DecodeNumber, ['1'] = DecodeNumber,
  ['2'] = DecodeNumber, ['3'] = DecodeNumber, ['4'] = DecodeNumber,
  ['5'] = DecodeNumber, ['6'] = DecodeNumber, ['7'] = DecodeNumber,
  ['8'] = DecodeNumber, ['9'] = DecodeNumber
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