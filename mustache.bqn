# Reference: http://mustache.github.io/mustache.5.html
#            https://juuso.dev/blogPosts/barbell/barbell.html
#            https://www.youtube.com/watch?v=5I4YPkVU7mY

# types
⟨ none, opn_bkt, cls_bkt, hash, slash, str,     # characters
  opn_dm, cls_dm,                               # markers
  tag, opn, cls, key                            # tags

  # mark as 
⟩ ← ↕12

labels ⇐ "f    s  tock"

# TODO use _while_
_Fix ← {𝔽∘⊢⍟≢⟜𝔽_𝕣∘⊢⍟≢⟜𝔽𝕩}

Delete ← { (/𝕨)(⊢-⍋)(¬𝕨)/𝕩 }
Parent ⇐ { g←⊔𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }
Depth  ← { p←𝕩 ⋄ d←p≠(↕≠p) ⋄ { z←𝕩⊏p ⋄ d+↩z≠𝕩 ⋄ z } _Fix p ⋄ d } 
Leaf   ⇐ { ¬(↕≠𝕩)⍷𝕩 }

⟨Draw⟩ ← •Import "tree.bqn" 

# parse namespaces and to parent tree
ParseNs ⇐ {
    𝕊 𝕩 :  
       ⟨s,d,t⟩ ← 0 𝕊 𝕩 
       m←0⊸=∘≠¨s ⋄ p←(Parent d) ⋄ r←(↕(≠s)-(≠/m))⌾((¬m)⊸/) (≠s)⥊¯1 ⋄ n← s↩(¬m)/s
       {ptr⇐[p,t,r], n⇐n};
  d 𝕊 ns : 6≡•Type ns ? 
    children←∾¨´{ ⟨⟨𝕩⟩, (d+1), ⟨'k'⟩⟩ ∾¨ (d+2) ParseNs (ns •ns.Get 𝕩) } ¨•ns.Keys ns
    ⟨⟨""⟩, ⟨d⟩, ⟨'o'⟩⟩ ∾¨ children;
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

  # find fragments and tags. ch no longer needed
    # collapse all zeros to frags and tag names
  { m←t=none ⋄ s←>⟜» m ⋄ e←>⟜« m 
    z←(0<t)∨(0<s) ⋄ t↩ z/t⌈s×str ⋄ n↩ ⊏⟜ch¨1↓⊔m∧+`s ⋄ r↩ (↕≠n)⌾((t=str)⊸/) (≠t)⥊¯1
  }

  # TODO multiple sources

  # find tags - delete open and close and lead with tag flag
  { o←t=opn_dm ⋄ c←t=cls_dm ⋄ z←¬c ⋄ t↩z/t⌈o×tag ⋄ r↩z/r }
  # mark opn tags - consume {# and set str as id (»»)
  { m←(t=tag)∧(«t=hash)∧(««t=str) ⋄ z←¬∨⟜»m ⋄ t↩z/t⌈»»m×opn ⋄ r↩z/r }
  # mark cls tags - consume {/ and set str as id (»»)
  { m←(t=tag)∧(«t=slash)∧(««t=str) ⋄ z←¬∨⟜»m ⋄ t↩z/t⌈»»m×cls ⋄ r↩z/r }
  # mark cls tags - consume { and set str as id (»)
  { m←(t=tag)∧(«t=str) ⋄ z←¬m ⋄ t↩z/t⌈(»m)×key ⋄ r↩z/r }
  # create parent vector
  { o←t=opn ⋄ c←t=cls ⋄ p↩Parent d←»+`o-c }
  # mark opn tags as keys
  { m←(t=opn) ⋄ t↩t⌈m×key }


  #Delete cls tags with unused names and shift r
  { m←(t=cls) ⋄ z←¬m ⋄ p↩m Delete p ⋄ t↩z/t ⋄ r↩ z/r-+`¬z ⋄ n↩ z/n } 

  { ptr⇐ [p, ⊢◶labels¨t, r] ⋄  n ⇐ n }
}

Compile ⇐ {
   𝕨 𝕊 𝕩 : (¬𝕩 •ns.Has "ptr")∧6≡•Type 𝕩 ? 𝕨 𝕊 (ParseNs 𝕩);
   𝕨 𝕊 𝕩 : 
    ⟨[tp,tt,tr]⇐ptr,tn⇐n⟩←𝕨 ⋄ ⟨[dp,dt,dr]⇐ptr,dn⇐n⟩←𝕩

    #data key parent vector
    dkp ← @ ⋄ dkr ← @
    #template key parent vector
    tkp ← @ ⋄ tkr ← @ 


     # create data parent vector of only keys
     {
      m←(dt='k')∧(dp=0)
      dkp↩  (/m)⌾(m⊸/) dp # set roots of keys

      dkp↩{𝕩⊏dkp}⌾((dt='k')⊸/) dkp # remap key parents to keys
      
      dkp↩ ((dt='o') ∨ (dt='v')) Delete dkp #delete objs and keys


      •Show (((dt='k')/dr)⊏dn) 
     (0⊑¨((dt='k')/dr)⊏dn) Draw dkp
      
     }

     # create template parent vector of only keys
    tkp ↩ (tt≠'k') Delete tp
    tkr ↩ (tt='k') / tr
    #(0⊸⊏¨tkr) Draw tkp
    #({0⊑𝕩⊑tn}¨tkr)  Draw tkp

       
    #(0⊸⊑¨(dt='k')⊏dn)Draw dkp

    #•Show tkr ⊏ tn
    #Draw tkp
    #tt Draw tp
    #•Show m←dt='k'
    #•Show m←dt='v'
    #•Show m/dt
    #(m/dt) Draw m Delete dp⊏dp

    #{ d← Depth dp ⋄ •Show d=⌜˜↕⌈´d+1 }
    #{ d← Depth tp ⋄ •Show d=⌜˜↕⌈´d+1 }

    #•Show (((dt='k')/dr)⊏dn)
    #•Show (((tt='k')/tr)⊏tn)
    #•Show (((dt='k')/dr)⊏dn)∊((tt='k')/tr)⊏tn

    #{
      #m← dt='k'

      #dt Draw dp
      #(m/dt) Draw m/dp⊏dp
    #}
    #td← Depth tp
    #•Show tr

    #dv ← ((dt='k')/dr)⊏dn
    #tv← (((tt='v')∨(tt='o'))/tr)⊏tn # variable names

    #dt Draw dp
    ## TODO check existence by depth
    #•Show dv‿tv
    #•Show dv∊tv
    # create key tree
    #dt Draw dp
}



#Compile0 ← {
  ## ip: replace parent, rv: replace values, r: references, t: types, p: parent, ch: characters, n: names
  #ip‿rv ← 𝕨 ⋄ rn ← (≠ip)⥊¯1 ⋄ ch ← •file.Chars 𝕩 ⋄ r ← (≠ch)⥊¯1 ⋄ t ← p ← (≠ch)⥊0 ⋄ n ← @

  #Print ← { 𝕊: •Show [ip, rv, rn] ⋄ •Show [p, t, r] ⋄ •Show n }

  #o‿c ← {∨⟜»⍟(1-˜≠𝕩)(≠ch)↑𝕩⍷ch}¨opn‿cls               # get open and close enclose bits
  #t ↩ +`(»>⟜«o)+-(»⊸<c)                               # pass: mark names in types
  #d ← (¬o∨c) ⋄ ch d⊸/ ↩ ⋄ p d⊸/ ↩ ⋄ t d⊸/ ↩ ⋄ r d⊸/ ↩ # pass: remove brackets

  ## pass: names to '$' tags with types and references to original names
  #{
    #i ← (0⊸≠≠¨)⊸/⊔(⊢-˜¬×+`)¬t=types.b

    #nm ← (¬∊⟜"#/")⊸/¨ ⊏⟜ch¨i # names: extracted tag strings
    #b ← (≠ch)↑(/⁼0⊑¨i) # base tags - opn of tags
    #s ← types.s×b∧ch='#' # opn tags
    #e ← types.e×b∧ch='/' # cls tags
    #d ← (t=types.b)×¬b

    #rn ↩ ¯1¨⌾(((≠nm)=nm⊐rv)⊸/) nm⊐rv
    #n  ↩ (≍⟜⊐) nm
    #r  ↩ (¬d)/(⊐nm)⌾(b⊸/) r
    #p  ↩ d Delete p
    #t  ↩ (¬d)/⌈´b‿s‿e
    #ch ↩ (¬d)/'$'¨⌾(b⊸/) ch
  #}


  #p ↩ +`(»>⟜«(t=types.s))+-(»⊸<(t=types.e))           # pass: construct parents from opn/cls tags

  #Print @
#}
