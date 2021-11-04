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

# File inclusion

```{.c include=test/test_include.c from=5}
```

```{include=test/test_include.c pattern="(main).-(%b{})" format="%1 = %2"}
```

:::{include=test/test_include.md shift=1}
:::

# Scripts

```{.class cmd="python %s"}
print("Pandoc is great!")
```

1 + 1 = `echo $((1+1))`{cmd=sh}

1 + 1 = `echo $((1+1))`{icmd=sh}

# Diagrams

```{render="{{plantuml}}" img="{{build}}/img/panda_plantuml_test" out="{{build}}/img" title="Alice & Bob"}
@startuml
Alice -> Bob: hello
@enduml
```

```{render="{{plantuml}}" title="Alice & Bob"}
@startuml
Alice -> Bob: hello
@enduml
```
