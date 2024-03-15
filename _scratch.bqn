
# delete leaf nodes - match to parent tree

⟨Draw⟩ ← •Import "tree.bqn" 
⟨Compile⟩ ← •Import "json.bqn" 

#p ← 0‿0‿1‿1‿1‿5‿5‿6‿6
#p ← 0‿0‿1‿1
#p ← 0‿0‿1‿1‿1‿5‿5‿6‿6‿0‿9‿9‿10


z← Compile "
{
  foo: [{
    bar: 1 
  },{
    bar: 2,
    baz: 2
  }]
}

"
[p,t,r] ←z.ptr
"abcdefghijlk" Draw p


