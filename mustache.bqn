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
PathMat ← { p←𝕨 ⋄ pp←𝕩 ⋄ {q←𝕩⊏p ⋄ pp ↩pp∾˘q ⋄ q} _Fix pp ⋄ ¯1↓˘pp }

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
  dmap←@ # map of data key indices to template key indices

  # find matching key paths
  { KP ← { p 𝕊 t: pp←/t='k' ⋄ { q←𝕩⊏p ⋄ pp↩pp∾˘q ⋄ q } _Fix pp ⋄ ¯1↓˘pp } # key paths. Drop self reference root
    trp←⊏⟜tr¨⍷¨<˘tp KP tt ⋄ dkp← {𝕩/˜'k'=𝕩⊏dt}¨<˘dp KP dt # trp: template reference path - key paths as references. dkp: key path of data with non key parents removed
    m←dt='k'⋄ map←¯1¨⌾((¬m)⊸/) { tn⊐𝕩⊏dn }⌾(m⊸/) dr # map of data keys to template keys (assumes keys point to unique names)
    dmap↩((¯1∾˜/tt='k')⊏˜trp⊐⊏⟜map¨dkp)⌾(m⊸/) ¯1¨dr # data mapping of keys to template reference map indices 
  } 

  # remove unneeded data (Helps with debuging)
  { z←(dt='k')∧(dmap=¯1) ⋄ { z↩z∨(𝕩⊏z) ⋄ 𝕩⊏dp} _fix dp          # prune key strings that don't exist path mapping
    dp↩z Delete dp ⋄ dt↩(¬z)/dt ⋄ dr↩(¬z)/dr ⋄ dmap↩(¬z)/dmap # mark unused data variables and remove orphanded children
  }                           

  { pp←v←dmap⊏˜dp⊏˜/dt='v' ⋄ { pp↩pp∾˘s←𝕩⊏tp ⋄ s } _fix pp ⋄ pp↩¯1↓˘pp # pp: parent path. Drop root self reference.

    •Show pp
    #•Show (/dt='v')⊏dp⊏dmap⊏tr⊏tn
    #•Show (0⊏˘pp)⊏tn
  }

}

Compile0 ⇐ {
 𝕨 𝕊 𝕩 : {6≡•Type 𝕩}◶0‿{¬𝕩 •ns.Has "ptr"} 𝕩 ? 𝕨 𝕊 (ParseNs 𝕩);
 𝕨 𝕊 𝕩 : {6≡•Type 𝕩}◶1‿{¬𝕩 •ns.Has "ptr"} 𝕨 ? (Parse 𝕨) 𝕊 𝕩;
 𝕨 𝕊 𝕩 : 
  ⟨[tp,tt,tr]⇐ptr,tn⇐n⟩←𝕨 ⋄ ⟨[dp,dt,dr]⇐ptr,dn⇐n⟩←𝕩
  out←@⋄ kn←((tt='k')/tr)⊏tn ⋄ dm←@ ⋄ tk←@ ⋄ dk←@  # kn: key strings. dm: lowest data keys that map to template key paths
  Dbn ←{{•Show (𝕩⊏tr)⊏tn}¨𝕩 } #debug names

  # create find matching reference paths from keys. 
  # ie foo->bar->baz in data matches with foo->bar->baz in template rather than foo->bar->quux
  { k←(((tt='k')/tr)⊏tn) ⋄ tk↩¯1¨tr ⋄ tk↩(kn⊐k)⌾((tt='k')⊸/) tk }
  { k←(((dt='k')/dr)⊏dn) ⋄ dk↩¯1¨dr ⋄ dk↩(kn⊐k)⌾((dt='k')⊸/) dk }                     # remap data key reference names to shared reference names to have common indices

  {
    dp
  }


  # match data key paths to template key paths
  { 
      •Show tp PathMat /(tt='k')
      •Show dp PathMat /(dt='k')

    trp← •Show ⊏⟜tk˘tp PathMat /(tt='k') ⋄ n←1⊑≢trp                                         # trp: template reference paths
    drp← •Show ⊏⟜dk˘{ m←𝕩/˜'k'=𝕩⊏dt ⋄ n↑m∾n⥊⊑⌽m }˘ dp PathMat /(dt='k')                     # drp: data reference paths



    ks←trp⊸⊐˘drp ⋄ k←/tt='k' ⋄ m←ks≠≠k ⋄ ks↩(⊏⟜k)⌾(m⊸/) ks ⋄ ks↩¯1¨⌾((¬m)⊸/) ks       # convert keyspace to normal index space with ¯1 as non index
    dm↩ks⌾((dt='k')⊸/) ¯1¨dt 
  }                                                        # mappings from data keys to template keys ¯1 if not a key

  { z←(dt='k')∧(dm=¯1) ⋄ { z↩z∨(𝕩⊏z) ⋄ 𝕩⊏dp} _fix dp                                  # prune key strings that don't exist path matrix ie don't exist as a tempalate variable. Helps with debuhing
    dp↩z Delete dp ⋄ dt↩(¬z)/dt ⋄ dr↩(¬z)/dr ⋄ dm↩(¬z)/dm }                           # mark unused data variables and remove orphanded children

  {
    #pp←v←dm⊏˜dp⊏˜/dt='v' ⋄ { pp↩pp∾˘s←𝕩⊏tp ⋄ s } _fix pp ⋄ pp↩1↓<˘⍉¯1↓˘pp # pp: parent path. Drop root self reference.
    pp←v←dm⊏˜dp⊏˜/dt='v' ⋄ { pp↩pp∾˘s←𝕩⊏tp ⋄ s } _fix pp ⋄ pp↩¯1↓˘pp # pp: parent path. Drop root self reference.

    #•Show pp
    #m←{ m←⊐+`»⊸≠𝕩 }¨pp
    ##r←{ ≠¨⊔𝕩 }¨m # repeats 
    #s← m { s←{/𝕩=tp}¨⊑¨𝕨⊔𝕩 }¨pp  # siblings list of each level
    #•Show m 
    #•Show ¨s
    #•Show {

      #(𝕩⊏tr)⊏tn

    #}¨s
    #•Show s
    #•Show r
    #•Show (1↓s) {
      #•Show 𝕨‿𝕩
    #} ¨(¯1↓m⊔¨pp)

    #u←{
      #s‿p←𝕩
      ##should not be first
    #}¨1↓s⋈¨(»p)
    #u← p { 𝕨=𝕩 }¨s # replacement mask for under operation
    #s↩r { 𝕨{ 𝕨⥊⟨𝕩⟩ }¨𝕩 }¨ s # flatten siblings

    #•Show s
    #•Show p
    #•Show u
    #•Show m
    #•Show p
    #•Show u
    #•Show s


    #•Show m
    #•Show "--"
    #•Show "--"

    #•Show m
    #•Show s
    #{
      #a‿b←𝕩
      #•Show bm←⊐+`»⊸≠b



    #} ¨¯1↓pp⋈¨«pp
    #{} ¨ pp


    #{  


    #}¨s

    
    #{
      #•Show "2"
      #•Show 𝕩
      #•Show m←⊐+`»⊸≠𝕩 
      #•Show s←{/𝕩=tp}¨⊑¨m⊔𝕩 

      
    #} 2⊑<˘⍉pp 

    #w←v
    #{
      #•Show "-"
      #m←⊐+`»⊸≠𝕩 
      #q←m⊔a 
      #p←⊑¨m⊔𝕩 
      #s←{/𝕩=tp}¨p

      #{
        #•Show [a,b,c]←𝕩
        #¨b
      #} ¨<˘⍉[s,m⊔a,m⊔w] 

      ##(⊑¨m⊔b) {
        ##p←𝕨
        ##•Show a
        ###•Show ⌾(𝕨=𝕩)
      ##}¨s

      

      #w↩𝕩

      ##•Show s
      ##•Show 𝕩
      ##•Show q { 
        
        ##•Show 𝕨‿𝕩
        ###𝕩¨⌾((𝕨⍷s)⊸/) s 
        ##𝕩
      ##}¨s

      #𝕩
      ##s←{/𝕩=tp}¨𝕩
      ##𝕨 { 
        ##s←/𝕩=tp
      ##}¨𝕩
    #}¨1↓<˘⍉pp
    

    #{
      #•Show "-"
      #•Show 𝕩
        ##s←{/𝕩=tp}¨𝕩⊏tp

      #•Show { 
        #{•Show 𝕩⊏tp}¨𝕩 
        #𝕩
      #}⌾(m⊸⊔) 𝕩

    #}¨<˘⍉pp

    ! 0
    #s←{
      #•Show "-"
      #m←⊐+`»⊸≠𝕩
      #q←⊑¨m⊔𝕩
      #z← ∾¨m⊔s←{/𝕩=tp}¨𝕩⊏tp

      #•Show z
      #•Show m
      #•Show a

      #•Show a↩q {
        #s‿a←𝕩 ⋄ ∾(a)⌾((𝕨⍷s)⊸/) s
      #} ¨z{𝕨‿𝕩}¨m⊔a
    #}¨2↑<˘⍉pp







    #a←@
    
        #s←𝕩 ⋄ p←/tp=𝕨⊏tp ⋄r←𝕨⍷p ⋄ n←(¬∨´𝕨⍷∾𝕩) # p: next parent list. r: current root position that will replace with current level references. n: number to children and number of times to duplicate current template level if the parent itself exist in parent list
    #v0←{
      #•Show "1"
      #p←𝕩⊏tp
      #•Show a↩ {/𝕩=tp}¨p
      #p
    #} v

    #v1←{
      #•Show "2"
      #•Show p←𝕩⊏tp
      #•Show m←⊐+`»⊸≠p
      #•Show s←{/𝕩=tp}¨p
      #•Show r←𝕩=s

      #a↩<˘{ s‿r‿a←𝕩 ⋄ ∾a¨⌾(r⊸/) s }˘⍉[s,r,a]
      #a↩ ∾¨m⊔a
      ##•Show ∾m⊔𝕩
      #p
    #} v0

    #v2←{
      #•Show "2"
      #•Show p←𝕩⊏tp
      #•Show m←⊐+`»⊸≠p
      #•Show s←{/𝕩=tp}¨p
      #•Show r←𝕩=s

      #a↩<˘{ s‿r‿a←𝕩 ⋄ ∾a¨⌾(r⊸/) s }˘⍉[s,r,a]
      #•Show a↩ ∾¨m⊔a
      #p
    #} v1
    #•Show pp↩(↕≠pp)∾˘pp
    #•Show p
    #a0←⟨⟩

    ## create parent mask
    #•Show pp
    #•Show (⍉«˘pp) {

    #•Show "--"
    #•Show 𝕨‿𝕩 

    #} ˘ ⍉pp

    #gp← { ∾⍷¨(1-˜+`»⊸≠𝕩)⊔𝕩 }¨1↓<˘⍉pp
    
    #a←(1-˜+`»⊸≠p0)⊔p0
    #{
      #•Show "-"
      #m←(1-˜+`»⊸≠𝕩)
      #•Show m
      #•Show a
      #•Show a↩ m⊔a
      ##•Show 𝕩

    #}¨gp
    #•Show {
      #•Show "--"
      ##•Show 𝕩
      ##•Show ⍷𝕩
      ##•Show g←(1-˜+`»⊸≠𝕩)
      ##•Show p←⍷¨g⊔acc
      #•Show 𝕨‿𝕩
      #•Show 𝕩
      #•Show ⊑
      #•Show (1-˜+`»⊸≠𝕩)⊔𝕨
      ##•Show (⍷¨1-˜+`»⊸≠𝕩)⊔𝕨
      ##a0↩a0∾⟨(1-˜+`»⊸≠𝕩)⊔acc⟩
      ##•Show (⊐𝕩)⊔acc
    #}`•Show <˘⍉pp

    •Out"  "

    #h←⟨⟩ ⋄ (↕≠v){ h↩h∾⟨(∊𝕩)/𝕨⟩⋄𝕨 }´ ⌽<˘gm ⋄ h↩⊐¨⍷h # h: hierarchy group list - shows the groups of corresponding children to parent. eg. ⟨⟨0 0 1 1⟩ ⟨0 1⟩⟩ groups indices 0 1 to group 0 and 2 3 to group 1 in the second list. 
    #dt Draw dp

  }
  # flattens tree into list of reference lists ordered by root nodes
  { 𝕊:
    p←v←/dt='v' ⋄ { p↩p∾˘s←𝕩⊏dp ⋄ s } _fix v 
    m←'o'=⊏⟜dt˘p ⋄ n←⌈´+´˘m # m : group objects mask in data. n
    •Show p
    •Show n
    •Show ˘m
    gm←⍉p{ z←𝕩/𝕨 ⋄ z∾(n-≠z)⥊¯1↑z }˘m #gm: group path matrix - allocate data leaf variables to groups depending on their parent paths. Runs top (variable) to bottom (parent) with zero being end of parent
    dt Draw dp
    #•Show m
    #•Show p
    #gm ↩ ⍉{ 𝕩+(⊑¯1↑(0≠𝕩)/𝕩)×0=𝕩 }˘⍉gm  # extend group paths to end and remove zeros
    #•Show gm

    h←⟨⟩ ⋄ (↕≠v){ h↩h∾⟨(∊𝕩)/𝕨⟩⋄𝕨 }´ ⌽<˘gm ⋄ h↩⊐¨⍷h # h: hierarchy group list - shows the groups of corresponding children to parent. eg. ⟨⟨0 0 1 1⟩ ⟨0 1⟩⟩ groups indices 0 1 to group 0 and 2 3 to group 1 in the second list. 
    #{
      #•Show gm
      #h←⟨⟩ 
      #(↕≠v){ 
        #•Show 𝕨
        #•Show 𝕩
        #h↩h∾⟨(∊𝕩)/𝕨⟩⋄𝕨 

      #}´ ⌽<˘gm 


      #h↩⊐¨⍷h # h: hierarchy group list - shows the groups of corresponding children to parent. eg. ⟨⟨0 0 1 1⟩ ⟨0 1⟩⟩ groups indices 0 1 to group 0 and 2 3 to group 1 in the second list. 
    #}

    e←dm⊏˜v⊏dp # e: matching template keys of data keys. Find the template keys that correspond to data keys in value list
    pp←⟨⟩ ⋄ { pp↩pp∾⟨e↩∾⍷¨𝕩⊔e⊏tp⟩ }¨h # pp: parent paths. Construct template parent indices of corresponding groups in h
    #{
      #e←dm⊏˜v⊏dp # e: matching template keys of data keys. Find the template keys that correspond to data keys in value list
      #pp←⟨⟩ 
      #{ 
        #•Show e⊏tp
        #pp↩pp∾⟨e↩∾⍷¨𝕩⊔e⊏tp⟩ 
      #} ¨h 
      #•Show ⟨↕≠⟩»pp
    #}
    # pp: parent paths. Construct template parent indices of corresponding groups in h
    f←⊑h # extract first since we're initializing first level
    
    p0←((≠pp)|1)↑1↓pp ⋄ h0 ←((≠h)|1)↑1↓h # case for when h and pp ≠ 1 
    #p0←((≠pp)|1)↑pp ⋄ h0 ←((≠h)|1)↑1↓h # case for when h and pp ≠ 1 

    #•Show h0
    #•Show p0


    #pp↩ ⟨1‿1⟩ ∾ 2↓pp # make sure pp groupings are kept consistent with h

    #pp↩ ¯1↓pp # make sure pp groupings are kept consistent with h
    #h ↩ 2↓h # replace parent groups with already processed item since we're initializing out with children 

    •Show h
    •Show pp
    #pp↩ p0 ∾ 1↓pp # make sure pp groupings are kept consistent with h

    out↩{ /tp=𝕩⊏tp }¨⊑¨f⊔dm⊏˜v⊏dp # initial setup of mapping leaf variables with siblings from parents
    #p0 { 
      #g←𝕩⊔𝕨 
      #•Show out {  
        #p⊏𝕨
      #}¨g
      ##o← »≠¨⍷¨𝕩⊔𝕨  # offsets
      #•Show out
      ##•Show ∾o+⊐¨g
    #}¨h0


    #out↩ f⊔dm⊏˜v⊏dp # initial setup of mapping leaf variables
    #•Show out

    #•Show h
    #•Show pp
    #•Show out

    #•Show /dt='k'
    #•Show (/tt='k')≍((tt='k')/tr)⊏tn
    #•Show (/dt='k')≍((dt='k')/dr)⊏dn
    ##•Show (/dt='o')≍((dt='o')/dr)⊏dn
    #•Show (/dt='v')≍((dt='v')/dr)⊏dn
    #•Show (/dt='v')⊏dp⊏dp
    #(dt) Draw dp

    pp {
      # find matching template parent and inject any children
      #•Show 𝕩⊔𝕨
      #•Show 𝕩
      #•Show 𝕨
      #•Show out
      #•Show 𝕩⊔out
      #•Show {•Show {(𝕩⊏tr)⊏tn}¨𝕩}¨𝕩⊔out
      out↩𝕨 {
        #•Show 𝕩
        #•Show ⊐𝕨
        #•Show (⊐𝕨)⊔𝕩
        #•Show (⊐𝕨)⊔𝕩
        

        s←𝕩 ⋄ p←/tp=𝕨⊏tp ⋄r←𝕨⍷p ⋄ n←(¬∨´𝕨⍷∾𝕩) # p: next parent list. r: current root position that will replace with current level references. n: number to children and number of times to duplicate current template level if the parent itself exist in parent list
        #•Show "--"
        #•Show 𝕨
        #•Show s
        #•Show p
        #•Show r
        #•Show ∾{∾(s¨⌾(r⊸/) p)}⍟n 𝕩 # replace matching root position with its children values 
        ∾{∾(s¨⌾(r⊸/) p)}⍟n 𝕩 # replace matching root position with its children values 
      }¨𝕩⊔out
    }¨h
  }

  # append roots and remove root keys (head of lists) which are no longer needed. r: roots, i: roots of subtrees (parts of template that have variables)
  { r←/tp=↕≠tp ⋄ i←⊑¨out ⋄ b←1↓¨out
    "processed subtrees should be roots of template tree" ! 1≡∧´i∊tp
    m←r∊(⍷i) # get unprocessed root nodes only
    out↩∾∾((⊐i)⊔b)⌾(m⊸/) r
  }

  # insert data values into out variable and sort in correct template order
  {
    v←/dt='v' ⋄ p←dm⊏˜v⊏dp ⋄ i←(⊐(v⊏dp)⊏dp) ⋄ g←i⊔p
    r←(≠tr)+∾(+`»≠¨g)+g⊐¨i⊔(/out∊p)⊏out
    out↩r⌾((out∊p)⊸/) out ⋄ tr↩tr∾(≠tn)+↕≠v ⋄ tn↩tn∾(dn⊏˜v⊏dr)
  }

  { out↩∾(out⊏tr)⊏tn} #render string result

  out
}

