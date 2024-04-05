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
PathMat ← { p←𝕨 ⋄ pm←𝕩 ⋄ {q←𝕩⊏p ⋄ pm ↩pm∾˘q ⋄ q} _Fix pm ⋄ ¯1↓˘pm }

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
  { o←t=opn ⋄ c←t=cls ⋄ p↩Parent d←»+`o-c }                                            # create parent vector
  { m←(t=opn) ⋄ t↩t⌈m×key }                                                            # mark opn tags as keys
  { m←(t=cls) ⋄ z←¬m ⋄ p↩m Delete p ⋄ t↩z/t ⋄ r↩ z/r-+`¬z ⋄ n↩ z/n }                   # Delete cls tags with unused names and shift r
  { r↩(⊐n)⌾((0≤r)⊸/) r ⋄ n↩ ⍷n }                                                       # remove duplicate strings
  { ptr⇐ [p, ⊢◶labels¨t, r] ⋄ n⇐n }
}

Compile ⇐ {
 𝕨 𝕊 𝕩 : {6≡•Type 𝕩}◶0‿{¬𝕩 •ns.Has "ptr"} 𝕩 ? 𝕨 𝕊 (ParseNs 𝕩);
 𝕨 𝕊 𝕩 : {6≡•Type 𝕩}◶1‿{¬𝕩 •ns.Has "ptr"} 𝕨 ? (Parse 𝕨) 𝕊 𝕩;
 𝕨 𝕊 𝕩 : 
  ⟨[tp,tt,tr]⇐ptr,tn⇐n⟩←𝕨 ⋄ ⟨[dp,dt,dr]⇐ptr,dn⇐n⟩←𝕩
  out←@⋄ kn←((tt='k')/tr)⊏tn ⋄ dm←@ ⋄ tk←@ ⋄ dk←@  # kn: key strings. dm: lowest data keys that map to template key paths
  # create find matching reference paths from keys. 
  # ie foo->bar->baz in data matches with foo->bar->baz in template rather than foo->bar->quux
  { k←(((tt='k')/tr)⊏tn) ⋄ tk↩¯1¨tr ⋄ tk↩(kn⊐k)⌾((tt='k')⊸/) tk }
  { k←(((dt='k')/dr)⊏dn) ⋄ dk↩¯1¨dr ⋄ dk↩(kn⊐k)⌾((dt='k')⊸/) dk }                     # remap data key reference names to shared reference names to have common indices
  { trp← ⊏⟜tk˘tp PathMat /(tt='k') ⋄ n←1⊑≢trp                                         # trp: template reference paths
    drp← ⊏⟜dk˘{ m←𝕩/˜'k'=𝕩⊏dt ⋄ n↑m∾n⥊⊑⌽m }˘ dp PathMat /(dt='k')                     # drp: data reference paths
    ks←trp⊸⊐˘drp ⋄ k←/tt='k' ⋄ m←ks≠≠k ⋄ ks↩(⊏⟜k)⌾(m⊸/) ks ⋄ ks↩¯1¨⌾((¬m)⊸/) ks       # convert keyspace to normal index space with ¯1 as non index
    dm↩ks⌾((dt='k')⊸/) ¯1¨dt }                                                        # mappings from data keys to template keys ¯1 if not a key
  { z←(dt='k')∧(dm=¯1) ⋄ { z↩z∨(𝕩⊏z) ⋄ 𝕩⊏dp} _fix dp                                  # prune key strings that don't exist path matrix ie don't exist as a tempalate variable. Helps with debuhing
    dp↩z Delete dp ⋄ dt↩(¬z)/dt ⋄ dr↩(¬z)/dr ⋄ dm↩(¬z)/dm }                           # mark unused data variables and remove orphanded children

  # flattens tree into list of lists of references to strings
  {
    p←v←/dt='v' ⋄ { p↩p∾˘s←𝕩⊏dp ⋄ s } _fix v 
    m←'o'=⊏⟜dt˘p ⋄ n←⌈´+´˘m
    gm←⍉p{ z←𝕩/𝕨 ⋄ z∾(n-≠z)⥊¯1↑z }˘m #gm: group path matrix - allocate data leaf variables to groups depending on their parent paths. Runs top (variable) to bottom (parent) with zero being end of parent
    gm ↩ ⍉{ 𝕩+(⊑¯1↑(0≠𝕩)/𝕩)×0=𝕩 }˘⍉gm  # extend group paths to end and remove zeros
    h←⟨⟩ ⋄ (↕≠v){ h↩h∾⟨(∊𝕩)/𝕨⟩⋄𝕨 }´ ⌽<˘gm ⋄ h↩⊐¨⍷•Show h # h: hierarchy group list - shows the groups of corresponding children to parent. eg. ⟨⟨0 0 1 1⟩ ⟨0 1⟩⟩ groups indices 0 1 to group 0 and 2 3 to group 1 in the second list. 
    e←dm⊏˜v⊏dp # e: matching template keys of data keys. Find the template keys that correspond to data keys in value list
    pp←⟨⟩ ⋄ { pp↩pp∾⟨e↩∾⍷¨𝕩⊔e⊏tp⟩ }¨h # pp: parent paths. Construct template parent indices of corresponding groups in h
    f←⊑h # extract first since we're initializing first level
    h↩⟨(⍷f)⟩∾1↓h # replace parent groups with already processed item since we're initializing out with children 
    out↩{/tp=𝕩⊏tp}¨⊑¨f⊔dm⊏˜v⊏dp # initial setup of mapping leaf variables
    pp {
      # find matching template parent and inject any children
      out↩𝕨 {
        s←𝕩 ⋄ p←/tp=𝕨⊏tp ⋄r←𝕨⍷p ⋄ n←(¬∨´𝕨⍷∾𝕩) # p: next parent list. r: current root position that will replace with current level references. n: number to children and number of times to duplicate current template level if the parent itself exist in parent list
        ∾{∾(s¨⌾(r⊸/) p)}⍟n 𝕩 # replace matching root position with its children values 
      }¨𝕩⊔out
    }¨h
  }

  # append roots and remove root keys (head of lists) which are no longer needed. r: roots, i: roots of subtrees (parts of template that have variables)
  { r←/tp=↕≠tp ⋄ i←⊑¨out ⋄ b←1↓¨out
    "processed subtrees should be roots of template tree" ! 1≡∧´i⊏tp
    m←r∊(⍷i) # get unprocessed root nodes only
    out↩∾∾((⊐i)⊔b)⌾(m⊸/) r
  }

  # insert data values into out variable and sort in correct template order
  {
    v←/dt='v' 
    p←dm⊏˜v⊏dp
    i←(⊐(v⊏dp)⊏dp)
    g←i⊔p
    r←(≠tr)+∾(+`»≠¨g)+g⊐¨i⊔(/out∊p)⊏out
    out↩r⌾((out∊p)⊸/) out
    tr↩tr∾(≠tn)+↕≠v
    tn↩tn∾(dn⊏˜v⊏dr)
  }

  { out↩∾(out⊏tr)⊏tn} #render string result

  •Show out
}

