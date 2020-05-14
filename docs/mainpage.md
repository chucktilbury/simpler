# SIMPLER

Simpler programming language

## Introduction

Simpler is a robust general purpose programming language. It is intended for general application development. This
implementation is a copiler that uses the LLVM backend to generate and run bytecode. In the future, I may compile to
native code if there is interest out in the real world.

### Why?

I am doing this as a hobby. I have no real expectation that Simpler will find much real-world use, but one may hope. I
have always wanted to create a language that I like. You might like it or not. I am open to ideas and sugestions.
Especially if you see something wrong in this document, I would like to know about it.

### Overview

Simpler is a compiled language intended for general purpose application development.
* Follows the C tradition of a small language that uses libraries. It also incorporates higher level features such
as lists and dictionaries (hash tables).
* Strongly typed. There are 4 first class types, Int, Float, String, and Boolean. A distinction is made between signed
and unsigned integers. Lists, Tuples, and Dictionaries are second class types that are containers for the first class
types.
* Lists, tuples, and dictionaries can contain any arbitrary combination of types.
* Iterators are implemented somewhat like Ruby using the ```yield``` keyword. Yield acts like ```return```, but the next
time the function with it is called, execution starts where it left off. When the function returns, the iterator
finishes.
* Switch/Case are supported and recognize strings as "cases".
* There is no ```for``` keyword. All loops are implemented with ```while``` and ```do{}while```.
* A while or do/while loop may have an ```else``` clause that is taken if the loop is not entered.
* Blank boolean expressesions are taken to be true.
* Structures are supported and may have methods defined for them. When a method is implemented for a structure, the
elements in the structure are scoped as local to the method. Structures can contain other structures with methods and
so on.
* Accessing structure elements is done by simple dot '.' notation and can be considered to be a sort of path to the
original definition of the element.
* Classes are not supported. (though they may be in the future)
* Nested functions are legal. A nested function can be accessed directly using dot notation.
