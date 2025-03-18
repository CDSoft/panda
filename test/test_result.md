---
boolean_metadata_false: false
boolean_metadata_true: true
number_metadata: 42
string_metadata: a string
title: Test document for *panda*
---

# Expansion

Input file: test/test.md

Output file: .build/test/test.md

``` lua
-- normal code block
-- foo = bar
-- bar = The title is: Test document for panda
-- baz = {{baz}}
-- email = [my email](me@example.com)
-- email2 = me2@example.com
-- sumsq100 = 338350
```

- title = "Test document for panda"
- string_metadata = a string (a string) a string, a string.
- boolean_metadata_true = true
- boolean_metadata_false = false
- number_metadata = 42
- foo = bar (bar) bar, bar.
- bar = The title is: Test document for panda
- baz = {{baz}}
- email = [my email](me@example.com)
- email2 = [eMail](mailto:me2@example.com)
- build directory = .build

::: { foo = bar } :::

[bar](bar/index.html)

## Header { foo = bar } {#header-foo-foo}

# Conditional blocks

## Comments

## Condition

<div>

foo is bar

</div>

<div>

`number_medatata` is 42

</div>

<div>

`boolean_metadata_false` is false

</div>

<div>

`string_metadata` is `"a string"`

</div>

Also works for inline spans. foo is bar and `string_metadata` is
`"a string"`

# File inclusion

``` c
int main(void)
{
    return 0;
}

/* foo */
```

    main = {
        return 0;
    }

## Title of the included file

Content of the included file (foo = bar)

## CSV

  Year   Score   Title
  ------ ------- ------------------------
  1968   86      Greetings
  1970   17      Bloody Mama
  1970   73      Hi, Mom!
  1971   40      Born to Win
  1973   98      Mean Streets
  1973   88      Bang the Drum Slowly
  1974   97      The Godfather, Part II
  1976   41      The Last Tycoon
  1976   99      Taxi Driver

# Documentation extraction

This is the main module documentation.

The main function is:

``` c
int main(void);
```

# Scripts

## No script name

``` class
Pandoc is great!
```

## Script name with implicit extension

``` class
Pandoc is great!
```

## Script name with explicit extension

``` class
Pandoc is great!
```

1 + 1 = `2`

1 + 1 = 2

## Script producing CSV tables

  X   Y   Z
  --- --- ---
  a   b   c

# Diagrams

![Alice &
Bob](.build/img/0ec62f1568ac33e20ec8d430ae77a9cbe6c9cd46.svg "Alice & Bob")

![Alice & Bob](.build/img/test-bob-and-alice.svg "Alice & Bob")

[![Alternative
description](.build/img/0ec62f1568ac33e20ec8d430ae77a9cbe6c9cd46.svg "Alice & Bob")](http://example.com "Alice & Bob")

[![Alternative
description](.build/img/test-bob-and-alice.svg "Alice & Bob")](http://example.com "Alice & Bob")

![](.build/img/9660f55f4f866c1e04f58eb9f9b88a3605d65d96.svg){.lua}

![](.build/img/dot.svg)
