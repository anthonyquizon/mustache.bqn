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

#p: previous value
_fix ← { Fn←𝔽 ⋄ p←@ ⋄ {r←p Fn 𝕩 ⋄ p↩𝕩 ⋄ r} •_while_ { 𝕩≢p } 𝕩 ⋄ p }

Delete ← { (/𝕨)(⊢-⍋)(¬𝕨)/𝕩 }
Parent ⇐ { g←⊔𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }
Depth  ← { p←𝕩 ⋄ d←p≠(↕≠p) ⋄ { z←𝕩⊏p ⋄ d+↩z≠𝕩 ⋄ z } _Fix p ⋄ d } 
Leaf   ⇐ { ¬(↕≠𝕩)⍷𝕩 }

⟨Draw⟩ ← •Import "tree.bqn" 

# parse namespaces and to parent tree
ParseNs ⇐ {
    𝕊 𝕩 :  
       ⟨s,d,t⟩ ← 0 𝕊 𝕩 
       m←0⊸=∘≠¨s ⋄ p←(Parent d) 
       # remove empty strings
       r←(↕(≠s)-(≠/m))⌾((¬m)⊸/) (≠s)⥊¯1 ⋄ n← s↩(¬m)/s
       # remove duplicate strings
       r↩(⊐n)⌾((0≤r)⊸/) r
       n↩ ⍷n 

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

  # remove comments
  #{ 
    #o←(t=opn_dm)∧(«t=bang) 
    #c←(t=cls_dm)
    #m←`o-c
    #•Show m

    ##⋄ z←¬∨⟜»m ⋄ t↩z/t⌈»»m×opn_com ⋄ r↩z/r 
    #}

  { o←t=opn_dm ⋄ c←t=cls_dm ⋄ z←¬c ⋄ t↩z/t⌈o×tag ⋄ r↩z/r } # find tags - delete open and close and lead with tag flag
  { m←(t=tag)∧(«t=hash)∧(««t=str) ⋄ z←¬∨⟜»m ⋄ t↩z/t⌈»»m×opn ⋄ r↩z/r } # mark opn tags - consume {# and set str as id (»»)
  { m←(t=tag)∧(«t=slash)∧(««t=str) ⋄ z←¬∨⟜»m ⋄ t↩z/t⌈»»m×cls ⋄ r↩z/r } # mark cls tags - consume {/ and set str as id (»»)
  { m←(t=tag)∧(«t=str) ⋄ z←¬m ⋄ t↩z/t⌈(»m)×key ⋄ r↩z/r } # mark cls tags - consume { and set str as id (»)
  { o←t=opn ⋄ c←t=cls ⋄ p↩Parent d←»+`o-c } # create parent vector
  { m←(t=opn) ⋄ t↩t⌈m×key } # mark opn tags as keys

  # TODO unique names

  { m←(t=cls) ⋄ z←¬m ⋄ p↩m Delete p ⋄ t↩z/t ⋄ r↩ z/r-+`¬z ⋄ n↩ z/n } #Delete cls tags with unused names and shift r

  # remove duplicate strings
   r↩(⊐n)⌾((0≤r)⊸/) r
  n↩ ⍷n

  { ptr⇐ [p, ⊢◶labels¨t, r] ⋄  n ⇐ n }
}

PathMat ← { p←𝕨 ⋄ pm←𝕩 ⋄ {q←𝕩⊏p ⋄ pm ↩pm∾˘q ⋄ q} _Fix pm ⋄ ¯1↓˘pm }
#GroupIn ← { 1-˜𝕩/+`>⟜»𝕩 }

# TODO rename n to s
Compile ⇐ {
 𝕨 𝕊 𝕩 : (¬𝕩 •ns.Has "ptr") ? 𝕨 𝕊 (ParseNs 𝕩);
 𝕨 𝕊 𝕩 : 
  ⟨[tp,tt,tr]⇐ptr,tn⇐n⟩←𝕨 ⋄ ⟨[dp,dt,dr]⇐ptr,dn⇐n⟩←𝕩
  kn←((tt='k')/tr)⊏tn #shared keys
  dm←@ ⋄ tm←@ # key match indices
  tk←@ ⋄ dk←@
  rp←⟨⟩⋄rr←⟨⟩⋄rn←⟨⟩

  { k←(((tt='k')/tr)⊏tn) ⋄ tk↩¯1¨tr ⋄ tk↩(kn⊐k)⌾((tt='k')⊸/) tk }
  # remap data key reference names to shared reference names to have common indices
  { k←(((dt='k')/dr)⊏dn) ⋄ dk↩¯1¨dr ⋄ dk↩(kn⊐k)⌾((dt='k')⊸/) dk }
  # create find matching reference paths from keys. 
  # ie foo->bar->baz in data matches with foo->bar->baz in template rather than foo->bar->quux
  {
    trp← ⊏⟜tk˘tp PathMat /(tt='k') ⋄ n←1⊑≢trp # trp: template reference paths
    drp← ⊏⟜dk˘{ m←𝕩/˜'k'=𝕩⊏dt ⋄ n↑m∾n⥊⊑⌽m }˘ dp PathMat /(dt='k') # drp: data reference paths
    ks←trp⊸⊐˘drp ⋄ k←/tt='k' ⋄ m←ks≠≠k ⋄ ks↩(⊏⟜k)⌾(m⊸/) ks ⋄ ks↩¯1¨⌾((¬m)⊸/) ks #convert keyspace to normal index space with ¯1 as non index
    dm↩ks⌾((dt='k')⊸/) ¯1¨dt  # mappings from data keys to template keys ¯1 if not a key
  }

  # prune key strings that don't exist path matrix ie don't exist as a tempalate variable. Helps with debuhing
  {
    z←(dt='k')∧(dm=¯1) ⋄ { z↩z∨(𝕩⊏z) ⋄ 𝕩⊏dp} _fix dp # mark unused data variables and remove orphanded children
    dp↩z Delete dp ⋄ dt↩(¬z)/dt ⋄ dr↩(¬z)/dr ⋄ dm↩(¬z)/dm
  }

  Draw dp
  #Draw tp
  #find leaf groups get 

  a←@
  {
    p←v←/dt='v' ⋄ { p↩p∾˘s←𝕩⊏dp ⋄ s } _fix v ⋄ p↩¯1↓˘p 
    m←'o'=⊏⟜dt˘p ⋄ •Show n←⌈´+´˘m
    gm←⍉p{ z←𝕩/𝕨 ⋄ z∾(n-≠z)⥊¯1↑z }˘m

    # TODO order keys correctly

    •Show gm
    # extend group paths to end
    gm ↩ ⍉{ 𝕩+(⊑¯1↑(0≠𝕩)/𝕩)×0=𝕩 }˘⍉gm
    k←(1↑<˘gm)⊔e←dm⊏˜v⊏dp
    h←⟨⟩ ⋄ (↕≠v){ h↩h∾⟨(∊𝕩)/𝕨⟩⋄𝕨 }´ ⌽¯1↓<˘gm ⋄ # hierarchy list drop root - handle that as different case 
    •Show gm
    h↩⊐¨⍷h

    ##p←{ p←⟨⟩ ⋄ { x←⊑𝕩⊏tp ⋄ p↩p∾x ⋄ x } _fix 𝕩 ⋄ p↩¯1↓p }¨g
    ##•Show h
    ##pp←⟨⟩ ⋄ { pp↩pp∾⟨s←𝕩⊏tp⟩⋄s } _Fix ⊑¨k ⋄ pp↩pp# template parent path

    ppath←⟨⟩
    { 
      ppath↩ppath∾⟨e↩∾⍷¨𝕩⊔e⊏tp⟩ 
    }¨h


    f←⊑h
    h↩1↓h
    ppath↩1↓ppath

    •Show h
    •Show ppath
    #•Show k
    ###•Show a←{/tp=𝕩}¨⊑ppath
    •Show a↩{/tp=𝕩⊏tp}¨⊑¨f⊔dm⊏˜v⊏dp

    •Show "=+++++++++="
    (ppath) {
      •Show "--"
      •Show 𝕨‿𝕩
      •Show a
      •Show 𝕨
      •Show 𝕩⊔a
      a↩𝕨 {
        •Show "+"
        •Show "𝕨"‿𝕨‿"𝕩"‿𝕩
        •Show p←/tp=𝕨⊏tp
        •Show r←𝕨⍷p
        •Show ¬∨´𝕨⍷∾𝕩
        n←(¬∨´𝕨⍷∾𝕩)
        •Show n
        s←𝕩
        #•Show "b" ‿b
        •Show z←∾{∾(s¨⌾(r⊸/) p)}⍟n 𝕩
        z
      }¨𝕩⊔a

      #•Show ((∾a)⊏tr)⊏tn
    }¨h
    #•Show (a)
  }

  # append roots and remove root keys from a
  {
    r←/tp=↕≠tp
    i←⊑¨a
    b←1↓¨a
    
    m←r∊(⍷i)
    a↩∾∾((⊐i)⊔b)⌾(m⊸/) r
  }

  # insert values 
  {
    v←/dt='v' 
    p←dm⊏˜v⊏dp
    r←(p⊐(/a∊p)⊏a)⊏(≠tr)+↕≠v # reorder values to match template order rather than data order
    a↩r⌾((a∊p)⊸/) a
    tr↩tr∾(≠tn)+↕≠v
    tn↩tn∾(dn⊏˜v⊏dr)
  }

  { a↩∾(a⊏tr)⊏tn} #render string result

  a
}

