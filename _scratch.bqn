
# delete leaf nodes - match to parent tree

⟨Draw⟩ ← •Import "tree.bqn" 
Parent ⇐ { g←⊔𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }
mustache ← •Import "mustache.bqn" 

##p ← 0‿0‿1‿1‿1‿5‿5‿6‿6
##p ← 0‿0‿1‿1
##p ← 0‿0‿1‿1‿1‿5‿5‿6‿6‿0‿9‿9‿10


##a ← {
  ##each⇐⟨
    ##{foo⇐111, bar⇐222}
    ##{foo⇐333, bar⇐444},
  ##⟩,
  ##peach⇐⟨
    ##{foo⇐111, quux⇐222}
    ##{foo⇐333, quux⇐444},
  ##⟩
##}

a ← {
  each⇐⟨
    {foo⇐111, bar⇐222}
  ⟩,
}


#⟨none, str, obj, arr, key, val⟩ ← ↕6
## 0 0 0 0 1 1 1 3 3 3
## 1 1 1 1 1 1 1 2 2 2
## e a c h f o o

#ParseNs ← {
    #𝕊 𝕩 : 0 𝕊 𝕩;
  #d 𝕊 ns : 6≡•Type ns ? 
    #•Show k←•ns.Keys ns
    #s←' '∾∾k
    #t←obj∾∾k
    #{(d+1) ParseNs ns •ns.Get 𝕩}¨k
    #•Show [s,t]

    ##s←•ns.Keys ns
    ## TODO add refs
    ##{s⇐s∾c.s }
    #⟨⟩
    #;

  #d 𝕊 𝕩 : 2≡•Type 𝕩 ? [[d],[val],[𝕩]] ;
  #d 𝕊 𝕩 : 0≡•Type 𝕩 ? 
    #•Show ≢⍉>(d+1)⊸ParseNs¨𝕩
    #⟨⟩
    #;

  #d 𝕊 𝕩 : d 𝕊 •Fmt 𝕩

  ##d 𝕊 s : (0≡•Type 𝕩) ? { s⇐⟨s⟩, d⇐⟨d⟩, t⇐⟨'v'⟩, r⇐⟨0⟩ } ; # parse string
  ##d 𝕊 a : 0≡•Type 𝕩 ? 
    ##c ←{(d+1) ParseNs 𝕩} ¨ a
    ##{ s⇐{𝕩.s}¨c, d⇐⟨d⟩∾{𝕩.d}¨c, t⇐⟨'a'⟩∾{𝕩.s}¨c, r⇐⟨¯1⟩∾{𝕩.s}¨c }
    ##•Show "list"
    ##•SHow 1
  ##;
  ##d 𝕊 n : 1≡•Type 𝕩 ? d 𝕊 •Fmt 𝕩
#}


# parse namespaces and to parent tree
ParseNs ← {
     𝕊 𝕩 :  
       ⟨s,d,t⟩ ← 0 𝕊 𝕩 
       m←0⊸=∘≠¨s ⋄ p←(Parent d) ⋄ r←(↕(≠s)-(≠/m))⌾((¬m)⊸/) (≠s)⥊¯1 ⋄ n← s↩(¬m)/s
       {ptr⇐[p,t,r], n⇐n}
  ;d 𝕊 ns : 6≡•Type ns ? 
    children←∾¨´{ ⟨⟨𝕩⟩, (d+1), ⟨'k'⟩⟩ ∾¨ (d+2) ParseNs (ns •ns.Get 𝕩) } ¨•ns.Keys ns
    ⟨⟨""⟩, ⟨d⟩, ⟨'o'⟩⟩ ∾¨ children 
  ;d 𝕊 𝕩 : 0≡•Type 𝕩 ? 
    { 𝕊 s : ∧´2⊸≡∘•Type¨s ? ⟨⟨s⟩, ⟨d⟩, ⟨'v'⟩⟩ ; # parse string
      𝕊 𝕩 : ∾¨´{ (d) ParseNs 𝕩}¨𝕩 
    } 𝕩
  ;𝕨 𝕊 𝕩 : 1≡•Type 𝕩 ? 𝕨 𝕊 •Fmt 𝕩
}

data ← ParseNs a

tpl ← data mustache.Parse (•file.Chars "test.mustache")

[p,t,r]←tpl.ptr
##•Show tpl.names
t Draw p

##tpl mustache.Compile data

