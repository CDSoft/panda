% Test document for *panda*

# Expansion

```meta
foo = "bar"
bar = "The title is: "..utils.stringify(title)
email = "[my email](me@example.com)"
```

```lua
-- normal code block
-- foo = {{foo}}
-- bar = {{bar}}
-- baz = {{baz}}
-- email = {{email}}
```

- title = {{title}}
- foo = {{foo}}
- bar = {{bar}}
- baz = {{baz}}
- email = {{email}}

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

```{.c include=test_include.c from=5}
```

```{include=test_include.c pattern="(main).-(%b{})" format="%1 = %2"}
```

:::{include=test_include.md shift=1}
:::

# Scripts

```{.class cmd="python %s"}
print("Pandoc is great!")
```

1 + 1 = `echo $((1+1))`{cmd=sh}

# Diagrams

```{render="{{plantuml}}" img="img/panda_plantuml_test" out="{{doc}}/img" title="Alice & Bob"}
@startuml
Alice -> Bob: hello
@enduml
```
