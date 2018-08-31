<h1 align="center">TinkerJson - 小巧而高速的JSON解析/生成器</h1>

## 简介

TinkerJson 是一个完全由 Lua 编写, 体积不足 500 行的小巧 JSON 处理工具. 它的运行速度很快, 事实上, 它是完全由 Lua 编写的 JSON 处理工具中运行速度最快的之一.

TinkerJson 能够将 JSON 文本转换为 Lua 中对应的类型, 同时也能将 Lua 中的数据类型序列化为 JSON 文本.

## 版本

v 2.0.0

<!-- ## 特性 -->

## 获取

TinkerJson 是一个开箱即用的工具, 它无需配置或安装, 只需获取源代码并将源代码置于项目目录中即可使用.

用户可以通过 `git clone` 获取最新的源代码:

```shell
git clone https://github.com/lytinker/Tinker_Json-Lua.git
```

也可以在 Github 页面下载压缩包.

TinkerJson 位于 `source/TkJson.lua` 中.

<!-- ## 安装 -->

<!-- ## 依赖 -->

## 用法

TinkerJson 为解析和生成 JSON 文本分别提供了一个方法, 分别是 `TkJson.Decode` 和 `TkJson.Encode`.

### 解析 JSON 文本

`TkJson.Decode` 方法的参数为待解析的 JSON 字符串, 返回解析生成的值或对象.

如果输入的 JSON 字符串不合法, 方法会报告错误并指出错误发生的位置.

**示例**

```lua
TkJson = require('TkJson')

json_text = [===[
  {
    "n": null,
    "f": false,
    "t": true,
    "i": 123,
    "s": "abc",
    "a": [ 1, 2, 3 ],
    "o": { "1": 1, "2": 2, "3": 3 }
  }
]===]
json_object = TkJson.Decode(json_text)

for key, value in pairs(json_object) do
  print(key .. ' ' .. tostring(value))
end
```

**输出**

```
t true
f false
s abc
a table: 0x130bab0
i 123
n null
o table: 0x130baf0
```

**示例**

```lua
TkJson = require('source/TkJson')

json_text = '{\"a\":{}'
json_object = TkJson.Decode(json_text)
```

**输出**

```
> Error: Line 1 Column 8 - Miss comma or curly bracket
stack traceback:
...
```

对于 JSON 中的布尔/数字/字符串类型, TinkerJson 会将它们分别转换为 Lua 中对应的的布尔/数字/字符串类型.

**示例**

```lua
bool1 = TkJson.Decode('true')
bool2 = TkJson.Decode('false')
print(type(bool1) .. ': ' .. tostring(bool1))
print(type(bool2) .. ': ' .. tostring(bool2))
print()

number1 = TkJson.Decode('20120330')
number2 = TkJson.Decode('3.1415926')
print(type(number1) .. ': ' .. tostring(number1))
print(type(number2) .. ': ' .. tostring(number2))
print()

string1 = TkJson.Decode('\"Hello TinkerJson!\"')
string2 = TkJson.Decode('\"\\uD834\\uDD1E\"')
print(type(string1) .. ': ' .. tostring(string1))
print(type(string2) .. ': ' .. tostring(string2))
```

**输出**

```
boolean: true
boolean: false

number: 20120330
number: 3.1415926

string: Hello TinkerJson!
string: 𝄞
```

TinkerJson 会将 `null` 转换为 `TinkerJson.null`(而非 Lua 中的 `nil`), 以避免 JSON 中值为 `null` 的键值对在 Lua 中被视作不存在的表项. 在输出时, `TinkerJson.null` 会打印为 `null`.

**示例**

```lua
null1 = TkJson.Decode('null')
print(null1)
print(null1 == TkJson.null)
```

**输出**

```
null
true
```

JSON 中的数组和对象类型会被解析为 Lua 中的 table 类型. 其中, TinkerJson 会自动为由数组类型解析得到的表添加一个额外的表项 `__length`, 指示数组中元素的个数.

**示例**

```lua
array1 = TkJson.Decode('[ null , false , true , 123 , \"abc\" ]')
print('length: ' .. tostring(array1.__length))
for i = 1, array1.__length do
  print('element ' .. tostring(i) .. ': ' .. tostring(array1[i]))
end
```

**输出**

```
length: 5
element 1: null
element 2: false
element 3: true
element 4: 123
element 5: abc
```

## 性能

### 测试文件

我们使用 `canada.json`, `twitter.json` 及 `citm_catalog.json` 三个文件进行性能测试, 其中:

* `canada.json`: 体积 2.3MB, 包含大量浮点数.
* `twitter.json`: 体积 632KB, 内容主要为 UTF-8 格式字符串.
* `citm_catalog.json`: 体积 1.7MB, 含有数字, 字符串, 数组等多种 JSON 类型.

### 参照

我们选取了 [Lua User Wiki](http://lua-users.org/wiki/JsonModules) 中列举的几种完全由 Lua 实现的 JSON 处理工具进行横向对比测试: 

* [json4lua](https://github.com/craigmj/json4lua)
* [dkjson](http://dkolf.de/src/dkjson-lua.fsl/home), 关闭 lpeg
* [jfjson](http://regex.info/blog/lua/json)
* [json.lua](https://github.com/rxi/json.lua)

### 解析 JSON 测试

解析 JSON 文本所用时长如下图所示(重复解析十次, 取平均值):

图

## 版权

本项目采用 MIT 许可证发布.

## 鸣谢

感谢我的好友 [**@tangyiyang**](https://github.com/tangyiyang), 在这个项目的实现过程中他提供了许多宝贵的指导和帮助.

感谢 [**@miloyip**](https://github.com/miloyip), 本项目的结构完全基于他的专栏文章 [从零开始的 JSON 库教程](https://zhuanlan.zhihu.com/json-tutorial).