<h1 align="center">TinkerJson-Lua - 小巧而高速的JSON解析/生成器</h1>

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

TinkerJson 为解析和生成 JSON 文本分别提供了一个方法, 分别是 `TkJson.decode` 和 `TkJson.encode`.

### 解析 JSON 文本

`TkJson.decode` 方法的参数为待解析的 JSON 字符串, 返回解析生成的值或对象.

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



## 性能

## 版权

## 鸣谢
