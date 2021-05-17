% Test document for *panda*

# Expansion

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

- title = {{title}}
- foo = {{foo}}
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

# Diagrams

```{render="{{plantuml}}" img="{{build}}/img/panda_plantuml_test" out="{{build}}/img" title="Alice & Bob"}
@startuml
Alice -> Bob: hello
@enduml
```
