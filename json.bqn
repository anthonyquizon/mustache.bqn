# simple json parser for input for mustache.bqn

Parse ← {
   ch ← 𝕩 ⋄ t ← @ ⋄ n ← @
   # pass: remove whitespace
   { ch (¬ch∊(@+10)‿' ')⊸/↩ }

   # pass: tag names 
   { 
     n←ch∊alphaNum ⋄ ch=':'
     e←0>n-»n
     ch≍n
     }
   
   #{ t↩«ch=':' }
  
   # pass: parse {} brackets
   #{ o←ch='{' ⋄ c← ch='}' ⋄ d←+`o-c }

} 

Parse "
{
  foo: {
    bar: [{x: 1, y: 2}, {x:3, y:3}],
    baz: {w: 8, z: 9}
  }
}
"
