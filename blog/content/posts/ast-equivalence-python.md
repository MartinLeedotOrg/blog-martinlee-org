---
title: "Testing code equivalence with Python's AST"
date: 2018-03-18T11:58:30Z
draft: false
---

## Intro

Going through the excellent videos from [PyCascades](https://www.pycascades.com/) I chanced upon Emily Morehouse-Valcarcel's fantastic presentation [The AST and Me](https://www.youtube.com/watch?v=Vkgb3fI8d7M).

Abstract:

> Get under the hood and learn about Python's beloved Abstract Syntax Tree. We'll discuss the AST's role in Python's compilation process, how it affects Bytecode, and how you can use it's optimizations to improve your code's speed at runtime. Write better code!

Rather than go in detail on the Abstract Syntax Tree, parse trees and bytecode in this post, I suggest you watch Emily's talk to gain an understanding of those concepts.

I was vaguely aware of how Python code was run, but Emily's talk inspired me to start playing with the AST. I decided to write a toy test case that I could use to prove that two pieces of code were, to CPython at least, identical.

All the code in this post is also in my GitHub repo [ast_equivalence](https://github.com/MartinLeedotOrg/ast_equivalence/).

### The Tester
```
#!/usr/bin/env python3
import ast
import unittest
import argparse
import dis

parser = argparse.ArgumentParser()
parser.add_argument("File1")
parser.add_argument("File2")
parser.add_argument("-v", dest="verbose", action="store_true")
args = parser.parse_args()


def get_bytecode(filename):
    with open(filename) as f:
        code = ast.parse(f.read())
        bytecode = dis.Bytecode(compile(code, '<string>', 'exec')).dis()
    return bytecode


bytecode1 = get_bytecode(args.File1)
bytecode2 = get_bytecode(args.File2)

if args.verbose:
    print(bytecode1)
    print(bytecode2)


class TestStringMethods(unittest.TestCase):
    if args.verbose:
        maxDiff = None

    def test_upper(self):
        self.assertEqual(bytecode1, bytecode2)


if __name__ == "__main__":
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(TestStringMethods)
    unittest.TextTestRunner().run(suite)

```

It took a little time to work out how to get a string of bytecode (hint, it's [`dis.Bytecode.dis()`](https://docs.python.org/3/library/dis.html#dis.Bytecode.dis)) but otherwise, pretty straightforward. I added a verbose option to print the bytecode and to allow the unittest to print the full diff.

### Example 1
A simple one - let's prove that, for the purposes of executing the code, tabs and spaces are the same.

#### ex1_spaces.py
```
#!/usr/bin/env python3

for i in range(10):
    print(i)
```

#### ex1_tabs.py
```
#!/usr/bin/env python3

for i in range(10):
	print(i)
```

Running `test.py ex1*` shows us that these two snippets are identical:
```
➜  ast_equivalence git:(master) ./test.py ex1*
.
----------------------------------------------------------------------
Ran 1 test in 0.000s

OK
```

No surprises here.

Recently, I came across some code which was both untested and mixed tabs and spaces for indentation.  Converting all indentation to spaces was simple enough, but now I can prove that I haven't introduced any bugs.

Here's what the output of `dis.Bytecode.dis()` looks like:
```
  3           0 SETUP_LOOP              24 (to 26)
              2 LOAD_NAME                0 (range)
              4 LOAD_CONST               0 (10)
              6 CALL_FUNCTION            1
              8 GET_ITER
        >>   10 FOR_ITER                12 (to 24)
             12 STORE_NAME               1 (i)

  4          14 LOAD_NAME                2 (print)
             16 LOAD_NAME                1 (i)
             18 CALL_FUNCTION            1
             20 POP_TOP
             22 JUMP_ABSOLUTE           10
        >>   24 POP_BLOCK
        >>   26 LOAD_CONST               1 (None)
             28 RETURN_VALUE
```

### Example 2
A little more complex. CPython performs [Peephole Optimisation](https://en.wikipedia.org/wiki/Peephole_optimization). Let's use that to prove that two logical statements are identical:

#### ex2_ainb.py
```
#!/usr/bin/env python3

a = 'apple'

b = {'apple', 'banana'}

print (a in b)
```

#### ex2_notanotinb.py
```
#!/usr/bin/env python3

a = 'apple'

b = {'apple', 'banana'}

print (not a not in b)
```

Once again, these are identical:
```
➜  ast_equivalence git:(master) ./test.py ex2*
.
----------------------------------------------------------------------
Ran 1 test in 0.000s

OK
```

Again, not hugely surprising, but if you're looking at a complex string of logic and algebra, this method might save you a few headaches.

## Disclaimer
This is not meant to test all cases where code should or shouldn't behave the same. As an example, we're testing for `STORE_NAME` being identical, although that doesn't always matter.  Consider an understanding of the `ast` and `dis` modules to be another tool in your debugging arsenal.
