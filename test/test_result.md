---
title: 'Test document for *panda*'
---

Expansion
=========

``` {.lua}
-- normal code block
-- foo = bar
-- bar = The title is: Test document for panda
-- baz = {{baz}}
-- email = [my email](me@example.com)
-- email2 = me2@example.com
```

-   title = Test document for *panda*
-   foo = bar
-   bar = The title is: Test document for panda
-   baz = {{baz}}
-   email = [my email](me@example.com)
-   email2 = [eMail](mailto:me2@example.com)

::: { foo = bar } :::

[bar](bar/index.html)

Header { foo = bar } {#header-foo-foo}
--------------------

Conditional blocks
==================

Comments
--------

Condition
---------

<div>

foo is bar

</div>

File inclusion
==============

``` {.c}
int main(void)
{
    return 0;
}

/* foo */
```

    main = {
        return 0;
    }

Title of the included file
--------------------------

Content of the included file (foo = bar)

Scripts
=======

``` {.class}
Pandoc is great!
```

1 + 1 = `2`

Diagrams
========

![](.build/img/panda_plantuml_test.svg "Alice & Bob")
