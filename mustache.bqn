# Reference: http://mustache.github.io/mustache.5.html
#            https://juuso.dev/blogPosts/barbell/barbell.html
#            https://www.youtube.com/watch?v=5I4YPkVU7mY

# types
⟨ none, opn_bkt, cls_bkt, hash, slash, str, bang,     # characters
  opn_dm, cls_dm,                   # markers
  tag, opn, cls, key                                  # tags
⟩ ← ↕13

labels ⇐ ∾⟨
  "f......",
  "..",
  "tock"
⟩

⟨Draw⟩←•Import "tree.bqn"
#p: previous value
_fix ← { Fn←𝔽 ⋄ p←@ ⋄ {r←p Fn 𝕩 ⋄ p↩𝕩 ⋄ r} •_while_ { 𝕩≢p } 𝕩 ⋄ p }

Delete ← { (/𝕨)(⊢-⍋)(¬𝕨)/𝕩 }
Parent ⇐ { g←⊔𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }
Depth  ⇐ { p←𝕩 ⋄ d←p≠(↕≠p) ⋄ { z←𝕩⊏p ⋄ d+↩z≠𝕩 ⋄ z } _Fix p ⋄ d } 

# parent paths - construct parent paths. Drop self reference root
PP ← { 
    𝕊 t‿p: (/t='k') PP t‿p;
  v 𝕊 t‿p: { v↩v∾˘q←𝕩⊏p ⋄ q } _Fix v ⋄ ¯1↓˘v 
} 

# parse namespaces and to parent tree
ParseNs ⇐ {
    𝕊 𝕩 :  
       ⟨s,d,t⟩ ← 0 𝕊 𝕩 
       {ptr⇐[Parent d,t,⊐s], n⇐⍷s};
  d 𝕊 ns : 6≡•Type ns ? 
    c←∾¨´{ ⟨⟨𝕩⟩, (d+1), ⟨'k'⟩⟩ ∾¨ (d+2) ParseNs (ns •ns.Get 𝕩) } ¨•ns.Keys ns
    ⟨⟨"⍉"⟩, ⟨d⟩, ⟨'o'⟩⟩ ∾¨ c;
  d 𝕊 𝕩 : 0≡•Type 𝕩 ?
    { 𝕊 s : ∧´2⊸≡∘•Type¨s ? ⟨⟨s⟩, ⟨d⟩, ⟨'v'⟩⟩ ; # parse string
      𝕊 𝕩 : ∾¨´{ (d) ParseNs 𝕩}¨𝕩 
    } 𝕩;
  𝕨 𝕊 𝕩 : 1≡•Type 𝕩 ? 𝕨 𝕊 •Fmt 𝕩
}


Parse ⇐ {
  ch←𝕩 ⋄ t←@ ⋄ r←@ ⋄ n←@ ⋄ p←@
  { t↩ ∨´⟨opn_bkt,cls_bkt,hash,slash⟩×ch⊸=¨"{}#/" }                                    # tokenize character types
  { m←t=opn_bkt ⋄ q←opn_dm×>⟜«m ⋄ z←(¬m)∨0<q ⋄ t↩z/t⌈q ⋄ ch↩z/ch }                     # find double opn brackets then collapse and mark into a delimeter
  { m←t=cls_bkt ⋄ q←cls_dm×>⟜«m ⋄ z←(¬m)∨0<q ⋄ t↩z/t⌈q ⋄ ch↩z/ch }                     # find double close brackets then collapse and mark into a delimeter
  { m←c∨+`(t=opn_dm)-(c←t=cls_dm) ⋄ t↩t×m }                                            # demote any characters outside delims as none
  { m←t=none ⋄ s←>⟜» m ⋄ e←>⟜« m                                                       # find fragments and tags. ch no longer needed
    z←(0<t)∨(0<s) ⋄ t↩ z/t⌈s×str ⋄ n↩ ⊏⟜ch¨1↓⊔m∧+`s ⋄ r↩ (↕≠n)⌾((t=str)⊸/) (≠t)⥊¯1 }   # collapse all zeros to frags and tag names
  { o←t=opn_dm ⋄ c←t=cls_dm ⋄ z←¬c ⋄ t↩z/t⌈o×tag ⋄ r↩z/r }                             # find tags - delete open and close and lead with tag flag
  { m←(t=tag)∧(«t=hash)∧(««t=str) ⋄ z←¬∨⟜»m ⋄ t↩z/t⌈»»m×opn ⋄ r↩z/r }                  # mark opn tags - consume {# and set str as id (»»)
  { m←(t=tag)∧(«t=slash)∧(««t=str) ⋄ z←¬∨⟜»m ⋄ t↩z/t⌈»»m×cls ⋄ r↩z/r }                 # mark cls tags - consume {/ and set str as id (»»)
  { m←(t=tag)∧(«t=str) ⋄ z←¬m ⋄ t↩z/t⌈(»m)×key ⋄ r↩z/r }                               # mark cls tags - consume { and set str as id (»)
  { o←t=opn ⋄ c←t=cls ⋄ p↩Parent d←»+`o-c ⋄ "unbalanced template tags"!0≡¯1⊑d }                                            # create parent vector
  { m←(t=opn) ⋄ t↩t⌈m×key }                                                            # mark opn tags as keys
  { m←(t=cls) ⋄ z←¬m ⋄ p↩m Delete p ⋄ t↩z/t ⋄ r↩ z/r-+`¬z ⋄ n↩ z/n }                   # Delete cls tags with unused names and shift r
  { r↩(⊐n)⌾((0≤r)⊸/) r ⋄ n↩ ⍷n }                                                       # remove duplicate strings
  { t↩ ⊢◶labels¨t  } # convert number types to character
  { ptr⇐ [p, t, r] ⋄ n⇐n }
}


Compile ⇐ {
 𝕨 𝕊 𝕩 : {6≡•Type 𝕩}◶0‿{¬𝕩 •ns.Has "ptr"} 𝕩 ? 𝕨 𝕊 (ParseNs 𝕩);
 𝕨 𝕊 𝕩 : {6≡•Type 𝕩}◶1‿{¬𝕩 •ns.Has "ptr"} 𝕨 ? (Parse 𝕨) 𝕊 𝕩;
 𝕨 𝕊 𝕩 : 
  ⟨[tp,tt,tr]⇐ptr,tn⇐n⟩←𝕨 ⋄ ⟨[dp,dt,dr]⇐ptr,dn⇐n⟩←𝕩
  out←@
  dmap←@ # map of data key indices to template key indices

  # find matching key paths
  { trp←⊏⟜tr¨⍷¨<˘ PP tt‿tp ⋄ dkp← {𝕩/˜'k'=𝕩⊏dt}¨<˘ PP dt‿dp # trp: template reference path - key paths as references. dkp: key path of data with non key parents removed
    m←dt='k'⋄ map←¯1¨⌾((¬m)⊸/) { tn⊐𝕩⊏dn }⌾(m⊸/) dr # map of data keys to template keys (assumes keys point to unique names)
    dmap↩((¯1∾˜/tt='k')⊏˜trp⊐⊏⟜map¨dkp)⌾(m⊸/) ¯1¨dr # data mapping of keys to template reference map indices 
  } 

  # remove unneeded data (Helps with debuging)
  { z←(dt='k')∧(dmap=¯1) ⋄ { z↩z∨(𝕩⊏z) ⋄ 𝕩⊏dp} _fix dp          # prune key strings that don't exist path mapping
    dp↩z Delete dp ⋄ dt↩(¬z)/dt ⋄ dr↩(¬z)/dr ⋄ dmap↩(¬z)/dmap # mark unused data variables and remove orphanded children
  }                           

  { 
    dpp←(dp⊏˜/dt='v') PP dt‿dp 
    dpp↩(¬2|↕≠⍉dpp)⊸/˘dpp # remove object parents
    tpp←⊏⟜dmap˘dpp

    #•Show ⌽⍉tpp
    #•Show ⌽⍉dpp

    #'n' Draw dp
    #•Show [(/dt='v'),(/dt='v')⊏dr⊏dn]
    #•Show [/(dt='v'), dp⊏˜/(dt='v'),(dp⊏˜/(dt='v'))⊏dr⊏dn,(dt='v')/dmap, (/dt='v')⊏dr⊏dn]
    #n←≠⍉dpp
    #•Show ⌽⍉{ u←⍷𝕩 ⋄ u/˜(1+n-≠u)∾1↓1¨u }˘dpp
    #•Show {⊐+`»⊸≠𝕩 }˘⌽⍉{ u←⍷𝕩 ⋄ u/˜(1+n-≠u)∾1↓1¨u }˘dpp
    •Exit 0
  }

  # append roots and remove root keys (head of lists) which are no longer needed. r: roots, i: roots of subtrees (parts of template that have variables)
  { r←/tp=↕≠tp ⋄ i←⊑¨out ⋄ b←1↓¨out
    "processed subtrees should be roots of template tree" ! 1≡∧´i∊tp
    m←r∊(⍷i) # get unprocessed root nodes only
    out↩∾∾((⊐i)⊔b)⌾(m⊸/) r
  }

  # insert data values into out variable and sort in correct template order
  {
    v←/dt='v' ⋄ p←dmap⊏˜v⊏dp ⋄ i←(⊐(v⊏dp)⊏dp) ⋄ g←i⊔p
    r←(≠tr)+∾(+`»≠¨g)+g⊐¨i⊔(/out∊p)⊏out
    out↩r⌾((out∊p)⊸/) out ⋄ tr↩tr∾(≠tn)+↕≠v ⋄ tn↩tn∾(dn⊏˜v⊏dr)
  }

  { out↩∾(out⊏tr)⊏tn} #render string result

  out
}

