# Reference: http://mustache.github.io/mustache.5.html
#            https://juuso.dev/blogPosts/barbell/barbell.html
#            https://www.youtube.com/watch?v=5I4YPkVU7mY
opn‿cls ← "{{"‿"}}"

L←•Show

# types
⟨ none, opn_bkt, cls_bkt, hash, slash, str,            # characters
  opn_dm, cls_dm, start_node, end_node      # nodes
⟩ ← ↕10

# TODO use _while_
_Fix ← {𝔽∘⊢⍟≢⟜𝔽_𝕣∘⊢⍟≢⟜𝔽𝕩}

Delete ← { (/𝕨)(⊢-⍋)(¬𝕨)/𝕩 }
Parent ← { g←⊔𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }
Depth  ← { p←𝕩 ⋄ d←p≠(↕≠p) ⋄ { z←𝕩⊏p ⋄ d+↩z≠𝕩 ⋄ z } _Fix p ⋄ d } 
Leaf   ⇐ { ¬(↕≠𝕩)⍷𝕩 }

# print without newline for debugging
Print ← {
  z←𝕨=@+10 
  •Show [' '¨⌾(z⊸/) 𝕨, 𝕩]
}

#TODO line number info
Compile ← {
  [rp,rt,rr]←𝕨.ptr ⋄ rn←𝕨.names ⋄ ch←𝕩 ⋄ t←p←(≠ch)⥊0 ⋄ r←@ ⋄ n←@ ⋄ d←@

  { t↩ ∨´⟨opn_bkt,cls_bkt,hash,slash⟩×ch⊸=¨"{}#/" }                                    # tokenize character types
  { m←t=opn_bkt ⋄ q←opn_dm×>⟜«m ⋄ z←(¬m)∨0<q ⋄ t↩z/t⌈q ⋄ ch↩z/ch }                     # find double start brackets then collapse and mark into a delimeter
  { m←t=cls_bkt ⋄ q←cls_dm×>⟜«m ⋄ z←(¬m)∨0<q ⋄ t↩z/t⌈q ⋄ ch↩z/ch }                     # find double close brackets then collapse and mark into a delimeter

  # find fragments and nodes. ch no longer needed
    # collapse all zeros to frags and node names
  { m←t=none ⋄ s←>⟜» m ⋄ e←>⟜« m ⋄ z←(0<t)∨(0<s) ⋄
    t↩ z/t⌈s×str ⋄ n↩ ⊏⟜ch¨1↓⊔m∧+`s ⋄ r↩ (↕≠n)⌾((t=str)⊸/) (≠t)⥊¯1
  }



  # find start nodes
  # find end nodes
  # find  nodes

  •Show [t,r]
  •Show n
  #{
    #o←(t=opn_dm)∧«(t=hash)
    #c←(t=cls_dm)

    ##i ← (0⊸≠≠¨)⊸/⊔(⊢-˜¬×+`)¬t=types.b

    #n←0<+`o-c # find name bounded
    #•Show ¬×+`o-c
    #z←o∨¬n∨c # collapse into open node
    ##•Show start_node×m
    ## TODO all the way to end delimeter and capture name
    ##t↩z/t⌈start_node×m
    ##ch↩z/ch
    ##•Show ∧⟜«m
  #}

  
  # find close node
  # fragment to close node

  #ch Print t
  #{ m←t=cls_bkt ⋄ t↩t∨cls_dm×»⊸< m ⋄ t (¬m)⊸/↩ ⋄ ch (¬m)⊸/↩ }                     # find double end brackets then collapse and mark as dmeter
  #{ 
    #•Show m←t=opn_dm  

    #⋄ t↩t∨hash×»⊸< m   ⋄ t (¬m)⊸/↩ ⋄ ch (¬m)⊸/↩



  #}                     # find double end brackets then collapse and mark as dmeter

  
  #o‿c ← {∨⟜»⍟(1-˜≠𝕩)(≠ch)↑𝕩⍷ch}¨opn‿cls                                               # get open and close enclose bits
  #{ t↩+`(»>⟜«o)+-(»⊸<c) }                                                             # mark names in types
  #{ d↩(¬o∨c) ⋄ ch d⊸/↩ ⋄ p d⊸/↩ ⋄ t d⊸/↩ ⋄ r d⊸/↩ }                                   # remove brackets

  #•Show (¬o∨c)

  #{ i←(0⊸≠≠¨)⊸/⊔(⊢-˜¬×+`)¬t=types.b ⋄ nm←(¬∊⟜"#/")⊸/¨ ⊏⟜ch¨i                          # names to '$' nodes with types and references to original names
    #b←(≠ch)↑(/⁼0⊑¨i) ⋄ s←types.s×b∧ch='#' ⋄ e←types.e×b∧ch='/' ⋄ del←(t=types.b)×¬b

    ##rn ↩ ¯1¨⌾(((≠nm)=nm⊐rv)⊸/) nm⊐rv
    #•Show nm
    #•Show s
    #•Show e
    #•Show ⌈´d
  #}
  #d ← (t=types.b)×¬b

}

#Compile0 ← {
  ## rp: replace parent, rv: replace values, r: references, t: types, p: parent, ch: characters, n: names
  #rp‿rv ← 𝕨 ⋄ rn ← (≠rp)⥊¯1 ⋄ ch ← •file.Chars 𝕩 ⋄ r ← (≠ch)⥊¯1 ⋄ t ← p ← (≠ch)⥊0 ⋄ n ← @

  #Print ← { 𝕊: •Show [rp, rv, rn] ⋄ •Show [p, t, r] ⋄ •Show n }

  #o‿c ← {∨⟜»⍟(1-˜≠𝕩)(≠ch)↑𝕩⍷ch}¨opn‿cls               # get open and close enclose bits
  #t ↩ +`(»>⟜«o)+-(»⊸<c)                               # pass: mark names in types
  #d ← (¬o∨c) ⋄ ch d⊸/ ↩ ⋄ p d⊸/ ↩ ⋄ t d⊸/ ↩ ⋄ r d⊸/ ↩ # pass: remove brackets

  ## pass: names to '$' nodes with types and references to original names
  #{
    #i ← (0⊸≠≠¨)⊸/⊔(⊢-˜¬×+`)¬t=types.b

    #nm ← (¬∊⟜"#/")⊸/¨ ⊏⟜ch¨i # names: extracted node strings
    #b ← (≠ch)↑(/⁼0⊑¨i) # base nodes - start of nodes
    #s ← types.s×b∧ch='#' # start nodes
    #e ← types.e×b∧ch='/' # end nodes
    #d ← (t=types.b)×¬b

    #rn ↩ ¯1¨⌾(((≠nm)=nm⊐rv)⊸/) nm⊐rv
    #n  ↩ (≍⟜⊐) nm
    #r  ↩ (¬d)/(⊐nm)⌾(b⊸/) r
    #p  ↩ d Delete p
    #t  ↩ (¬d)/⌈´b‿s‿e
    #ch ↩ (¬d)/'$'¨⌾(b⊸/) ch
  #}


  #p ↩ +`(»>⟜«(t=types.s))+-(»⊸<(t=types.e))           # pass: construct parents from start/end nodes

  #Print @
#}


json ← •Import "./json.bqn"

data ← json.Compile "
   {
      each: [ foo: 111, bar: 222 ]
   }
"

•Show data.ptr‿data.names

data Compile (•file.Chars "test.mustache")

#data ←  ⟨
  #⟨"points", ⟨
      #⟨"cx", "10"⟩, ⟨"cy", "1"⟩
      #⟨"cx", "10"⟩, ⟨"cy", "1"⟩
  #⟩⟩,
#⟩

#•Show (Flatten data)
#•Show (Depth ⟨⟩)
#•Show (Depth data)≍(Flatten data)
#•Show Parent 0‿1‿2‿1‿2‿3‿2‿1‿2‿3‿3‿2‿3‿3‿2
#p ← (Parent (nested.Depth data))
#v ← (nested.Flatten data)
#L Depth p

#d ← [0,       1,         1,    2,    3,    2,    3]
#v ← ⟨"points","foo", "bar", "cx", "10", "cy", "12"⟩

#d ← ∨´(↕≠p)⊸=¨1‿2
## (⍸M)(⊢-1+⍸)(~M)⌿P
#L (¬d)
#L (/d)
#L (¬d)/p 
###L (/d)(⊢-1+/)(¬d)/p 


#L x ← 0‿0‿1‿0‿3‿0‿5
##L v
##L p
#L ((¬d)/v)≍x
#L ((¬d)/p)-x

#L (/d)(⊢-1+/)(¬d)/p


#{

#L p←0‿0‿1‿2‿20‿4‿4‿6‿7‿20‿9‿10‿10‿10‿9‿14‿15‿20‿17‿18‿2
#L t←3‿2‿1‿10‿4‿10‿2‿0‿7‿4‿2‿10‿9‿10‿2‿0‿7‿2‿0‿7‿3
#L (p⊏t)=4


#}

#{
  #p ← 0‿0‿0‿3‿3‿3
  #c ← "abcdef"
  #L [p,c]

   
#}



#p‿v Compile "test.mustache"

#•Show "done"
