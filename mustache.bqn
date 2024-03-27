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

  # TODO unique names

  #Delete cls tags with unused names and shift r
  { m←(t=cls) ⋄ z←¬m ⋄ p↩m Delete p ⋄ t↩z/t ⋄ r↩ z/r-+`¬z ⋄ n↩ z/n } 


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

  {
    p←v←/dt='v' ⋄ { p↩p∾˘s←𝕩⊏dp ⋄ s } _fix v ⋄ p↩¯1↓˘p 
    m←'o'=⊏⟜dt˘p ⋄ •Show n←⌈´+´˘m
    gm←⍷⊐˘⍉p{ z←𝕩/𝕨 ⋄ z∾(n-≠z)⥊¯1↑z }˘m

    # TODO order keys correctly

    k←(1↑<˘gm)⊔e←dm⊏˜v⊏dp
    h←⟨⟩ ⋄ (↕≠v){ h↩h∾⟨(∊𝕩)/𝕨⟩⋄𝕨 }´ ⌽¯1↓<˘gm ⋄ # hierarchy list drop root - handle that as different case 

    #p←{ p←⟨⟩ ⋄ { x←⊑𝕩⊏tp ⋄ p↩p∾x ⋄ x } _fix 𝕩 ⋄ p↩¯1↓p }¨g
    #•Show h
    #pp←⟨⟩ ⋄ { pp↩pp∾⟨s←𝕩⊏tp⟩⋄s } _Fix ⊑¨k ⋄ pp↩pp# template parent path

    ppath←⟨⟩
    { 
      ppath↩ppath∾⟨e↩∾⍷¨𝕩⊔e⊏tp⟩ 
    }¨h

    •Show h↩1↓h
    •Show ppath↩1↓ppath
    •Show k
    #•Show a←{/tp=𝕩}¨⊑ppath
    •Show a←{/tp=𝕩⊏tp}¨⊑¨k

    (ppath) {
      •Show "--"
      •Show 𝕨‿𝕩
      a↩•Show 𝕨 {
        •Show "+"
        •Show 𝕩
        •Show p←/tp=𝕨⊏tp
        #•Show s←
        •Show r←(𝕨⍷p)
        •Show z←∾∾(𝕩¨⌾(r⊸/) p)
      }¨𝕩⊔a

      #•Show (a)
      #•Show ((∾a)⊏tr)⊏tn
      #•SHow (a⊏tr)⊏tn
    }¨h

      •Show (((1=∾a)/∾a)⊏tr)⊏tn
      •Show ((∾a)⊏tr)⊏tn

    #pp {
      #p←𝕨
      #•Show "--"
      #•Show 𝕨‿𝕩
      #•Show 𝕩⊔k
      #•Show k↩∾¨𝕨 {
        #•Show 𝕨‿𝕩
        #(/tp=𝕨)¨𝕩
      #} ¨ 𝕩⊔k
      #@
    #} ¨ h

    #{
      #•Show "--h"
      #s← { /tp=⊑𝕩⊏tp }¨k
        ###•Show r←𝕩⍷/tp=𝕩⊑tp
        ##•Show r←(𝕨⍷s)
        ##•Show c↩∾(c¨⌾(r⊸/) s)∾⟨⟨⟩⟩
      #•Show s
      #•Show k↩∾¨𝕩⊔s


    #}¨h


    #rp←tp
    
    #{
      #•Show "---"
      #•Show 𝕩‿𝕨
      #•Show k
      #•Show ((∊𝕩)/𝕨)
      #k↩{ 
        #p←⊑𝕩⊏tp 
        #s←/(p=tp) # siblings
        #𝕩
        #s
      #}¨𝕩⊔k

      #•Show k

      #(∊𝕩)/𝕨
    #}´ ⌽<˘gm
    #k {
      #•Show "---"
      ##•Show s←/(rp∊𝕩⊏rp) # siblings
      #•Show 𝕨
      #•Show 𝕩
      #•Show (≠𝕩)‿(≠𝕨)
      #g←𝕨⊔𝕩
      #•Show { 
        #p←⊑𝕩⊏tp 
        #•Show s←/(p=tp) # siblings

        #s
      #}¨g
    #}´ ⌽<˘gm

    #gm←⊐˘⍉km #group matrix
      #•Show "+++"
      #•Show gm
    #k {
      #•Show "---"
      #•Show 𝕨‿𝕩
      ##•Show s←/(rp∊𝕩⊏rp) # siblings
      ##•Show 𝕩⊏rp

      ###•Show r←pp=/pi # replace index. the previous parent where we want to inject our previous values
      ##•Show 𝕨⊔s
      ##s
    #}´⌽<˘gm
    #v {
      #•Show 𝕩
      #•Show 𝕨
      ##•Show p←k⊏tp
      ##•Show 𝕩⊔k
      #𝕨
    #} gm
    #{
      #•Show s←(tp=𝕩⊑tp) # siblings
      #•Show /s
      ##•Show ∾𝕩¨⌾((𝕩=/s)⊸/) /s

    #}¨k
    
    #•Show¨(⊐1⊏˘km)⊔k
    #•Show¨(⊐2⊏˘km)⊔k
    #p←{ p←⟨⟩ ⋄ { x←⊑𝕩⊏tp ⋄ p↩p∾x ⋄ x } _fix 𝕩 ⋄ p↩¯1↓p }¨g
    #•Show g←(+`(»≠⟜«k))⊔dm⊏˜dp⊏˜v # group of template parents of values
  }

  #{
    #•Show { 𝕩 }¨↕d
    #•Show o←(v/dp)⊏dp   # o->k->v objects are groups
    #•Show o⊏dp⊏dp   # o->k->v objects are groups


    #{
      #o←(v/dp)⊏dp   # o->k->v objects are groups
      #g←(+`(»≠⟜«o))⊔dm⊏˜dp⊏˜/v # group of template parents of values
    #}

    #•Show ⟨⟨⟨7,5⟩,⟨7,5⟩⟩,⟨⟨7,5⟩,⟨7,5⟩,⟨7,5⟩⟩⟩
    #•Show tn↩tn∾(v/dr)⊏dn
    #•Show (p⊏tr)⊏tn
    #template children with parent p
    #v0←⋈¨i⊔p

    # setup initial with siblings
    #v0←{ 
      #p← ⊑𝕩⊏tp
      #p‿(
    #}¨i⊔p

      #•Show "=="
      #•Show "=="
      #•Show "=="
    #p←{ p←⟨⟩ ⋄ { x←⊑𝕩⊏tp ⋄ p↩p∾x ⋄ x } _fix 𝕩 ⋄ p↩¯1↓p }¨g
    #c←(p) { 
      #c←/tp=⊑𝕨
      #•Show {
      #•Show "--"
        #•Show 𝕨‿𝕩
        #•Show c
        #•Show s←/tp=𝕩
        ##•Show r←𝕩⍷/tp=𝕩⊑tp
        #•Show r←(𝕨⍷s)
        #•Show c↩∾(c¨⌾(r⊸/) s)∾⟨⟨⟩⟩

        ## replace index. the previous parent where we want to inject our previous values
      #}´𝕨
      #c
    #} ¨(g)

    #•Show c
    #•Show ((∾c)⊏tr)⊏tn
    #p←{⊑𝕩⊏tp}¨g
    #q←{/tp∊𝕩⊏tp}¨g

    ##•Show p {
      ##•Show 𝕨‿𝕩
      ##s←(tp=𝕨⊑tp) # siblings (ie nodes with shared)
      ##•Show r←𝕨=/s # replace index. the previous parent where we want to inject our previous values
      ##•Show p←⊑pi/tp

    ##}¨ q


    #q↩p { 
      #tp=𝕨⊑tp
      #s←(tp=𝕨⊑tp) ⋄ ∾𝕩¨⌾((𝕨=/s)⊸/) /s 
    #}¨q
    #p↩{⊑(tp=𝕩⊑tp)/tp}¨p # siblings (ie nodes with shared)

    ##•Show p
    ##•Show q

    #q↩p{
      #•Show 𝕨
      #•Show tp=𝕨⊑tp

      #s←(tp=𝕨⊑tp) ⋄ 

      #•Show 𝕨=/s
      #∾𝕩¨⌾((𝕨=/s)⊸/) /s
    #}¨ q
    #p↩{
      #⊑(tp=𝕩⊑tp)/tp
    #}¨p # siblings (ie nodes with shared)

    #•Show p
    #•Show q

    #•Show v0

    #v1 ← {
      #pp‿x ←𝕩
      #•Show pi←(tp=pp⊑tp) # siblings (ie nodes with shared)
      #•Show r←pp=/pi # replace index. the previous parent where we want to inject our previous values
      #•Show p← ⊑pi/tp

      #p‿(∾x¨⌾(r⊸/) /pi)
    #} ¨v0

    #v2 ← {
      #pp‿x ←𝕩
      #•Show pi←(tp=pp⊑tp) # siblings (ie nodes with shared)
      #•Show r←pp=/pi # replace index. the previous parent where we want to inject our previous values
      #•Show p← ⊑pi/tp

      #p‿(∾x¨⌾(r⊸/) /pi)
    #} ¨v1

    #•Show v1
    #•Show v2


    #v1←{
      #p←𝕩⊏tp⊏tp
      #•Show 𝕩⊏tp
      #•Show (/tp∊p)

      #r←p∊𝕩
      ##•Show p∊𝕩
      ##•Show p
      ##•Show 𝕩
      ##∾𝕩¨⌾(r⊸/) p
    #}¨v0

    #•Show v1

    #v2←{
      #p←/tp∊𝕩⊏tp⊏tp
      #r←p=⊑𝕩⊏tp
      #∾𝕩¨⌾(r⊸/) p
    #}¨v1

    #•Show v2


    # apply roots
    #v2←{
      #•Show "--"
      #•Show 𝕩
      #•Show 𝕩⊏tp
      #p←/tp∊𝕩⊏tp⊏tp
      #r←p=⊑𝕩⊏tp
      #∾𝕩¨⌾(r⊸/) p
    #}¨v1

    #•Show v0
    #•Show v1
    #•Show v2
    #v3←{
      #•Show ((⊑𝕩⊏tp)⊏tr)⊏tn
      #•Show p←/tp∊𝕩⊏tp
      #r←p=⊑𝕩⊏tp
      #∾𝕩¨⌾(r⊸/) p
    #}¨v2

    #v4←{
      #p← /tp∊𝕩⊏tp⊏tp
      #r←p=⊑𝕩⊏tp
      #∾𝕩¨⌾(r⊸/) p
    #}¨v3

    #v5←{
      #p← /tp∊𝕩⊏tp⊏tp
      #r←p=⊑𝕩⊏tp
      #∾𝕩¨⌾(r⊸/) p
    #}¨v4

    #ii←(∾v1)
    #zz←(ii∊p)
    #ttr←ii⊏tr
    #n←(v/dr)⊏dn
    #ttn←tn∾n

    #ttr↩((≠tr)+↕≠n)⌾(zz⊸/) ttr
    #•Show ttr⊏ttn

    #m←tp∊p⊏tp #template children with parent p
    #•Show +`(1»≠⟜«m) # group indices
    #•Show m
    #•Show a←/v
    #{
      #a↩a∾˘𝕩
      #𝕩⊏dp
    #} _fix a

    #a↩⌽1↓⍉a
    #r←a⊏dm
    #•Show r↩(∨´˘r≠¯1)/r
    #{
      #•Show ⍉𝕩⊏⍉r
    #}¨ i⊔↕≠i
    #get siblings
    #•Show p←dm⊏˜dp⊏˜/v # template parents of values
  #}
  
  #{
    #v←dt='v'
    #p←dm⊏˜dp⊏˜/v # template parents of values
    #o←(v/dp)⊏dp   # o->k->v objects are groups
    #i←+`(»≠⟜«o) # group indices
    #g←i⊔p

    #rp←tp
    #rn←tn
    #rr←tr
    #•Show "--====="
    #{
      #acc←⟨⟩
      #{
        #•Show "--"
        ## left and right and
        #•Show m←/tp∊𝕩
        #acc


        ##•Show i←+`(1»≠⟜«m) # group indices

        ##•Show r←(≠tp)↑/⁼𝕩 # repeat variables
        ##x ← ∾{ ∾⟨𝕩⟩/˜1⌈⌈´𝕩⊏r }¨i⊔↕≠tp # repeat pattern

        ##•Show x⊏tp
        ##•Show x⊏tr
        ##•Show x
        ##•Show r
        ##•Show tp
        ##•Show x⊏tp
        ##•Show 𝕩
        #𝕩⊏tp
      #} _Fix 𝕩
    #}¨1↑g
  #}

  #{𝕊:
    ## group by data depth
    #v←dt='v'
    #n←(v/dr)⊏dn
    #p←dm⊏˜dp⊏˜/v # template parents of values
    


    #{
      #•Show "--"
      #•Show 𝕩
      #•Show m←tp∊𝕩⊏tp #template children with parent p
      #•Show i←+`(1»≠⟜«m) # group indices
      #•Show r←(≠tp)↑/⁼𝕩 # repeat variables
      #•Show x ← ∾{ ∾⟨𝕩⟩/˜1⌈⌈´𝕩⊏r }¨i⊔↕≠tp # repeat pattern

      #p⊏tp
    #} _Fix p


    #m←tp∊p⊏tp #template children with parent p
    #i←+`(1»≠⟜«m) # group indices
    #r ← (≠tp)↑/⁼p # repeat variables
    #x ← ∾{ ∾⟨𝕩⟩/˜1⌈⌈´𝕩⊏r }¨i⊔↕≠tp # repeat pattern

    ## go through parent tree and append siblings

    ##•Show (↕≠tp)≍tp
    ##•Show (↕≠tp)⊏tn
    ##•Show (tp∊((((↕≠tp)⊏tp)⊏tp)))

    ##ttr←x⊏tr
    ##tr↩((≠tr)+↕≠n)⌾((ttr∊p)⊸/) ttr
    ##tp↩x⊏tp
    ##tn↩tn∾n

    ##•Show tp
    ###•Show tp≍tr
    ##•Show tr⊏tn
    ##•Show tp⊏tp


    ##•Show {{(⌈´𝕩)¨𝕩}¨𝕩}⌾(i⊸⊔) (≠tp)↑/⁼p

    ##•Show i⊔↕≠tp
    ##•Show 1¨⌾(m⊸/) ↕≠tp
    ##•Show 1¨⌾(m⊸/) ↕≠tp
    ##•Show {

      ##•Show 𝕩⊏r
      ##•Show 𝕩
      ##𝕩
    ##}⌾(m⊸/) ↕≠tp
    ##•Show {s←⌈´𝕩 ⋄ s¨𝕩}¨i⊔q

    

    ##•Show m
    ##•Show z←⌈`(»<⟜«m)×↕≠tp
    ##•Show (0<q)
    ##•Show (0<q)×+`1»≠⟜«m
    ##•Show (/m)⍋(/0<q)
    ## get siblings
    

    ##•Show (⊒p)/tp
    ##•Show tp↩(⊒p)/tp
    ##•Show (m/tr)⊏tn
    ##•Show ⌾(p⊸/) ↕≠tp
    ##•Show k←m∧tt='k' # template key children 
    ##•Show m←tp∊p⊏tp # template children with 𝕩 as parent


    ##{
      ##•Show v⊏dn
      ##•Show m←tp∊𝕩 # template children with 𝕩 as parent
      ##•Show k←m∧tt='k' # template key children 
      ###•Show q←(1-˜+`0=(≠k)|↕≠𝕩) # group indices

      ###•Show 𝕨‿𝕩‿(𝕨≠𝕩)
      ###TODO only update items that have changed
      ##p⊏tp
    ##} _Fix p

    ##•Show (p⊏tr)⊏tn
    ##•Show (p⊏tp⊏tr)⊏tn
    ##•Show (p⊏tp⊏tp⊏tr)⊏tn
  #}

  #{
    #k←/dt='k'
    #v←/dt='v'
    #•Show p←v⊏dp
    #•Show ((/tt='k')⊏tr)⊏tn
    #•Show dm
    #•Show tn
    #•Show 
    #•Show ((((k∊p)/dm)⊏(/tt='k'))⊏tr)⊏tn
    ## set values

    ##•Show dt='k'
    ##•Show k
    ##•Show dm
    ##•Show k∊tm
    ##•Show (k⊏dr)⊏dn
    ##•Show ((/tt='k')⊏tk)⊏kn

    ##•Show (((¬k∊tm)/k)⊏dr)⊏dn
    ## get siblings
    
  #}

  #Draw dp 
  #Draw tp



    #z←((≠kn)=m)⌾((dt='k')⊸/) (≠dt)⥊0 ⋄ 


    #•Show ((/dt='k')⊏dr)⊏dn

    #•Show k

    #•Show tm
    #•Show dm

    #•Show ¬k∊tm
    #•Show (((¬k∊tm)/k)⊏dr)⊏dn

    #v←/dt='v'
    #p←v⊏dp
    #m←(/k)∊tm
  #{
    #•Show (/k∊p)∊ # get parents in key index space
    #•Show (((/k∊p)⊏tm)⊏tr)
    #•Show ((/k∊p)⊏dk)⊏kn
    #•Show (/k∊p)⊏dm
  #}

  # fill all value level data
  #{
    #d← Depth tp ⋄ tki←1-˜+`tk←tt='k'

    #{ 
      #m←d=𝕩∧tk
      #•Show m
      #•Show p←(/m)⊏tp
      #•Show q←(1-˜m/+`>⟜»m)
      
      #•Show i←(dt='v')∧dp∊(dm∊/m)//dt='k' # data value indices of mapped template keys at current depth
        #v←⊏⟜dn⊏⟜dr o⊏i # values

        ##i←/(dt='v')∧dp∊(dm∊k)//dt='k'# indices of values and also if its parents equal to the mapped keys 

      #@
    #}¨⟨2⟩#⌽↕⌈´d+1

    #{
      #•Show tk
      ##•Show k←𝕩⊏tk # key indices
      #•Show 𝕩∧
    #}˘
  #}

  #{
    #d← Depth tp ⋄ tk←1-˜+`tt='k'
    #{
      #m←d=𝕩
      #p←(/m)⊏tp
      #q←(1-˜m/+`>⟜»m)
        #•Show "xxx"

      #(∾⍷¨q⊔p) {
        #m←'k'=𝕩⊏tt # key mask
        #k←(m/𝕩)⊏tk # key indices
        #•Show m
        ##s← ⊏⟜tn 𝕩⊏tr # strings
        #•Show "--"

        #•Show i←/(dt='v')∧dp∊(dm∊k)//dt='k'# indices of values and also if its parents equal to the mapped keys (from data mapping key table)
        #•Show q←(1-˜+`0=(≠k)|↕≠i) # group indices
        #•Show k⊐(dm∊k)/dm
        #•Show q
        #o←(q×≠k)+k⊐(dm∊k)/dm # index order mapping with offset depending on group
        #v←⊏⟜dn⊏⟜dr o⊏i # values

        ## add values to tree

        ##n ← ∾{(𝕩)⌾(m⊸/) s} ¨q⊔v
        
        ##rr↩ (≠rn)¨⌾(𝕨⊸⊏) rr
        ##rn↩rn ∾ ⟨n⟩
      #}¨q⊔(/m)

      ## set all used data types to value
      ##{
        ##m←'k'=𝕩⊏tt # key mask
        ##k←(m/𝕩)⊏tk # key indices
        ##i←/(dt='v')∧dp∊(dm∊k)//dt='k'# indices of values and also if its parents equal to the mapped keys 
        ##dt↩ 'v'¨⌾(i⊸⊏) dt
      ##}¨q⊔(/m)
    #}¨⟨2,1⟩

  #}
    #}¨⌽↕⌈´d+1 # depth level matrix 


    #m←d=⌈´d # lowest depth
    #tk←tt='k'
    #•Show tl←(1-˜+`tk)/˜m∧tk # indices of template keys in key array (ie. array if there were only keys) that are lowest

    ## separate out parents

    ## template parents mapped to children data of matching data parents 
    #•Show n←(≠tl)
    #•Show i←dm/˜dm∊tl
    #•Show g←tl⊸⊐¨(1-˜+`0=n|↕≠i)⊔i # group as set indices in v
    #•SHow v←⊏⟜dn⊏⟜dr/((dt='v')∧dp∊(dm∊tl)//dt='k')

    #•Show pi ←(1-˜m/+`>⟜»m) # parent group indices
    ##•Show m
    ##•Show (tk∧m)/tk×(0-˜+`m)
    ##•Show tk
    ##•Show z←(tk∧m)/tk×(0-˜+`m)
    #•Show s←⊏⟜tn¨pi⊔(/m)⊏tr

    ## grouped values
    #•Show vg←(⊏⟜v¨g+¨n×↕≠g)

    #s { 𝕩 }¨vg
    #•Show /m⊏tr⊏tn
    #•Show { 
      #•Show z
      ##•Show 𝕩⊏tn
      #•Show nn←
      #𝕩‿𝕨 

    #}¨
    #•Show nn←((/m)⊏tr)⊏tn
    #•Show {(𝕩)⌾(z⊸⊏) nn} # access value with key offsets


    #•Show (1-˜+`tk)
    #•Show ((/m)⊏tr)⊏tn
    #•Show tl

    # 
    # mark 

    #•Show (m∧tk)
    #•Show ((m∧tk)/tr)⊏kn
    #•Show ((m∧¬tk)/tr)⊏tn
    #•Show tl⊏tm # map template keys to data vales

    #rr↩rr∾(≠rr)+↕≠m
    #rn↩rn∾(dr/˜dt='v')⊏dn

    #•Show rr
    #•Show rn

    #dt ↩ 'v'¨⌾(m⊸⊏) dt 

  #}
  #
}


Compile0 ⇐ {
   𝕨 𝕊 𝕩 : (¬𝕩 •ns.Has "ptr") ? 𝕨 𝕊 (ParseNs 𝕩);
   𝕨 𝕊 𝕩 : 
    ⟨[tp,tt,tr]⇐ptr,tn⇐n⟩←𝕨 ⋄ ⟨[dp,dt,dr]⇐ptr,dn⇐n⟩←𝕩

    #data key parent vector. dki -> original indices
    dkp ← @ ⋄ dkr ← @ ⋄ dki ← @ 
    #template key parent vector
    tkp ← @ ⋄ tkr ← @ ⋄ tki ← @


     # create data parent vector of only keys
     {
      m←(dt='k')∧(dp=0)
      dkp↩(/m)⌾(m⊸/) dp # set roots of keys
      dkp↩{𝕩⊏dkp}⌾((dt='k')⊸/) dkp # remap key parents to keys
      dkp↩((dt='o') ∨ (dt='v')) Delete dkp #delete objs and values

      dkr↩(dt='k')/dr
      dki↩(dt='k')/↕≠dt
     }

     # create template parent vector of only keys
    tkp ↩ (tt≠'k') Delete tp
    tkr ↩ (tt='k') / tr
    tki ↩ (tt='k') / ↕≠tr

    # set data key indices to match template indices and remove any non existing keys
    {
      # find names that don't exist in template variables
      e←(tkr⊏tn)⊐(dkr⊏dn)
      # z mask to remove all non existing data names and delete all children with deleted parents
      z←(≠tkr)=e ⋄ { z↩z∨(𝕩⊏z) ⋄ 𝕩⊏dkp} _fix dkp
      # map references to names that do exist to matching template references
      m←⊏⟜tkr⌾(((≠tkr)≠e)⊸/) e
      # delete all references that do not have a name variable in template
      # delete all children of parents of non existing vars
      dkp↩z Delete dkp
      dkr↩(¬z)/m
      dki↩(¬z)/dki
    }

    # extract valid paths
    {
      PathMat ←{
        d←Depth 𝕩
        dm←d=⌜˜↕⌈´d+1 
        dm↩ ⌈`˘⍉+`˘⍉(↕≠𝕨)⊸×˘dm
        ⊏⟜𝕨˘dm
      }
      •Show dpm ← dkr PathMat dkp
      •Show tpm ← tkr PathMat tkp
      •Show dpmatch ← (<˘⍉tpm)⊐(<˘⍉dpm)
      •Show tpmatch ← (<˘⍉dpm)⊐(<˘⍉tpm)
      

      # for each data at lowest find matching template

      td←Depth tp
      dd←Depth dp


      #{
        #•Show 𝕩
        ##k←dt='k'
        #m←dd=𝕩∨(dt='v')
        #z←m

        ##parent of children k->v -> then rematch as v
        #•Show pp←⊑⟜dp¨/z
        ###•Show (⊑⟜dp¨/z)⊏dt

        ##(pp⊏dr)⊏dn

        ### map to key index
        ##•Show pp
        ##•Show dki
        ### match to template depth path matrix index
        #•Show pp⊏dpmatch
        ##•Show dpmatch
        #zz←pp⊏dpmatch

        ## get surrounding sibling fragments ie same parents
        ##•Show zz
        ##•Show /⁼zz
        #•Show qq←∨´{ 𝕩=tp }¨zz⊏tkp⊏tki
        ##•Show zz⊏tki

        #•Show fg← ((/qq)⊏tr)⊏tn # fragments
        #•Show k← (zz⊏tkr)⊏tn
        #•Show v← (z/dr)⊏dn # values

        ##•Show k⊐fg
        ##•Show mm ← fg∊k
        ##•Show in←(mm/k⊐fg)⊸⊏ v
        ##•Show in⌾(mm⊸/) fg

        ### apply 

        #•Show cn← (zz⊏tkr)⊏tn
        #•Show cr← ↕≠cn
        #•Show cp← ↕≠cn

        ##cp‿cr‿cn
      #}¨ ⟨⌈´td⟩

    }


    #{ 𝕊:

      #•Show tpm
      #•Show tpmatch

      #•Show dpm
      #•Show dpmatch

      #•Show k←tt='k'
      #•Show m←d=⌈´d
      #•Show z←(m∧k)
      #r ←tr(⊢/×)z # references for current depth
      
      #•Show tn⊏˜tr(⊢/×)z
      #•Show /(z×tr)/tn

      #•Show d≍tkp
      ## while


      # get children of depth x
        # get parent
          # separate to parent
            # parent key is now children rendered
          

      #•Show (m∧k)×tp⊏tp
      # replace 
      #•Show ⌾((0>z)⊸/) z
    #}




    #{
      #d←Depth dkp
      #dm←d=⌜˜↕⌈´d+1 
      #•Show dkr
      #•Show dm
      #•Show ⍉+`˘⍉dm
      ##•Show {  ⊐⌾(𝕩⊸/) dkr}˘dm
    #}

    #{
      #d←Depth tkp
      #•Show tkr
      #dm←d=⌜˜↕⌈´d+1 
      #•Show dm
      ##•Show {(≠d)↑𝕩/tkr}˘dm
    #}
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
