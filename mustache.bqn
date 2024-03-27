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

  # append roots
  {
    •Show "--"
    •Show r←/tp=↕≠tp
    •Show i←⊑¨a
    •Show b←1↓¨a
    
    •Show m←r∊(⍷i)
    •Show a↩∾∾((⊐i)⊔b)⌾(m⊸/) r

    •Show ((a)⊏tr)⊏tn
  }
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
