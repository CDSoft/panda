---
title: Test document for *panda*
string_metadata: "a string"
boolean_metadata_true: true
boolean_metadata_false: false
number_metadata: 42
---

# Expansion

Input file: {{input_file}}

Output file: {{output_file}}

```meta
foo = "bar"
bar = "The title is: "..utils.stringify(title)
email = "[my email](me@example.com)"
sumsq = function(n) return F.range(n):map(function(x) return x*x end):sum() end
sumsq100 = sumsq(100)
```

```{.meta include=test/test.lua}
```

```lua
-- normal code block
-- foo = {{foo}}
-- bar = {{bar}}
-- baz = {{baz}}
-- email = {{email}}
-- email2 = {{email2}}
-- sumsq100 = {{sumsq100}}
```

- title = "{{title}}"
- string\_metadata = {{string_metadata}} ({{string_metadata}}) {{string_metadata}}, {{string_metadata}}.
- boolean\_metadata\_true = {{boolean_metadata_true}}
- boolean\_metadata\_false = {{boolean_metadata_false}}
- number\_metadata = {{number_metadata}}
- foo = {{foo}} ({{foo}}) {{foo}}, {{foo}}.
- bar = {{bar}}
- baz = {{baz}}
- email = {{email}}
- email2 = [eMail](mailto:{{email2}})

::: { foo = {{foo}} }
:::

[{{foo}}]({{foo}}/index.html)

## Header { foo = {{foo}} }

# Conditional blocks

## Comments

::: comment
blabla
:::

## Condition

::: {.if foo=bar}
foo is bar
:::

::: {.if foo=baz}
foo is baz
:::

::: {.if baz=yo}
baz is yo
:::

::: {.if number_metadata=42}
`number_medatata` is 42
:::

::: {.if number_metadata=43}
`number_medatata` is 43
:::

::: {.if boolean_metadata_false=true}
`boolean_metadata_false` is true
:::

::: {.if boolean_metadata_false=false}
`boolean_metadata_false` is false
:::

::: {.if string_metadata="string"}
`string_metadata` is `"string"`
:::

::: {.if string_metadata="a string"}
`string_metadata` is `"a string"`
:::

Also works for inline spans.
[foo is bar]{.if foo=bar}
[foo is baz]{.if foo=baz}
and
[`string_metadata` is `"string"`]{.if string_metadata="string"}
[`string_metadata` is `"a string"`]{.if string_metadata="a string"}

# File inclusion

```{.c include=test/test_include.c from=15}
```

```{include=test/test_include.c pattern="(main).-(%b{})" format="%1 = %2"}
```

:::{include=test/test_include.md shift=1}
:::

## CSV

:::{.csv include=test/test.csv}
:::

# Documentation extraction

:::{doc=test/test_include.c from="@@@main"}
:::

# Scripts

## No script name

```{.class cmd="python"}
print("Pandoc is great!")
```

## Script name with implicit extension

```{.class cmd="python %s"}
print("Pandoc is great!")
```

## Script name with explicit extension

```{.class cmd="python %s.py"}
print("Pandoc is great!")
```

1 + 1 = `echo $((1+1))`{cmd=sh}

1 + 1 = `echo $((1+1))`{icmd=sh}

## Script producing CSV tables

```{.python .csv icmd="python"}
print("X, Y, Z")
print("a, b, c")
```

# Diagrams

```{render="{{plantuml}}" img="{{build}}/img/panda_plantuml_test" out="{{build}}/img" caption="Alice & Bob"}
@startuml
Alice -> Bob: hello
@enduml
```

```{render="{{plantuml}}" caption="Alice & Bob" alt="Alternative description" target="http://example.com"}
@startuml
Alice -> Bob: hello
@enduml
```

```{.lua render="{{lsvg}}" img="{{build}}/img/lsvg_test" out="{{build}}/img"}
local w, h = 320, 240
img {
    width = w,
    height = h,
    font_size = h/2,
    text_anchor = "middle",
    Text "lsvg" { x=(w/2, y=h/2, dy="0.25em", fill="red" },
}
```
