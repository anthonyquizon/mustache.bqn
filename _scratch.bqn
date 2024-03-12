
# delete leaf nodes - match to parent tree


#p ← 0‿0‿1‿1‿1‿5‿5‿6‿6
p ← 0‿0‿1‿1‿1‿5‿5‿6‿6‿0‿9‿9‿10
q ← 0‿0‿2‿2

_Fix ← {𝔽∘⊢⍟≢⟜𝔽_𝕣∘⊢⍟≢⟜𝔽𝕩}
Depth  ← { p←𝕩 ⋄ d←p≠(↕≠p) ⋄ { z←𝕩⊏p ⋄ d+↩z≠𝕩 ⋄ z } _Fix p ⋄ d } 
Delete ← { (/𝕨)(⊢-⍋)(¬𝕨)/𝕩 }
Leaf ← { ¬(↕≠𝕩)⍷𝕩 }

# example:
# ○
# ├─┬─┐
# ○ ○ ○

type ← { none⇐0 ⋄ node⇐1 ⋄ horz⇐2 ⋄ mid⇐3 ⋄ start⇐4 ⋄ end⇐5 ⋄ vert⇐6 }

Draw ← {
  r ← {𝕩⊏p} _fix p ⋄ d ← Depth 𝕩                      # r: roots. d: depth

  {
    •Show "-"
    m← 𝕩=r                                            # mask for current root
    par←@ ⋄ h←@ ⋄ n←@

    par↩{ (1+𝕩/m/p)⌾(𝕩⊸/) 𝕩 }˘m⊸/˘d=⌜˜↕⌈´d+1          # depth matrix to parent vector offset by 1 since null values are 0
    par↩∾˘(↕≠par) {«⍟𝕨 𝕩} ˘par                        # shift diagonal zeros to vertical line


    e←par×>⟜«˘par
    s←par×>⟜»˘par
    s↩s×∊˘s          # mark first starts of parent
    e↩e×{⌽∊⌽𝕩}˘e     # mark first endings of parent

    n↩(<2)‿(<2)/par
    n↩0<{«𝕩∧2|↕≠𝕩}˘0¨⌾((2|↕≠n)⊸/) n               # nodes by finding every second level then every second item within the level

    h↩ par⌈+`˘s-e  # extend parents to horizontal 
    h↩(<2)‿(<2)/h # create pad spacing
    h↩h∧¬{𝕩>«𝕩}˘h # remove overflow hendings
    h↩«0¨⌾((2|↕≠h)⊸/) h # bars on every second level and shift up
    h↩type.horz×0⊸< h # set base type for bars
    h↩h⌈(type.start×>⟜»˘h)+(type.end×>⟜«˘h)           # find start and end bars
    h↩h⌈type.mid×«n                                   # find mid bars that have children
    h↩h⌊type.vert                                     # clamp to vertical bar if both start and end

    •Show n⌈h

    #•Show ≢h
    #•Show 1‿1/[(≠h)⥊1,(≠h)⥊0]
    #extend until
    #par↩(<2)‿(<2)/par                                 # pad offsets for render characters

    #n←0<{«𝕩∧2|↕≠𝕩}˘0¨⌾((2|↕≠par)⊸/) par               # nodes by finding every second level then every second item within the level
    #•Show par

    #h←par∧¬{𝕩>«𝕩}˘par # remove overflow hendings
    #h↩type.horz×0⊸< «0¨⌾((2|↕≠h)⊸/) h                 # nodes by finding every second level then every second item within the level
    #•Show 0<s
    #h↩h⌈(type.start)+(type.end×>⟜«˘h)           # find start and end bars
    #•Show h
    #•Show {𝕩>«𝕩}˘h
    #•Show {𝕩>»𝕩}˘h
    #•Show h
    #•Show s
    #•Show +`s-e
    #•Show h←{(0<⌈`𝕩)∧⌽0<⌈`⌽𝕩}˘par
    #•Show h←(+`˘par-e)∧˘{ (0<+`𝕩)∧⌽0<+`⌽𝕩 }˘par               # extended parents across horizontal

    #h↩{0¨⌾((>⟜«𝕩)⊸/) 𝕩}˘h                             # remove overflow endings
    #h↩h⌈(type.start×>⟜»˘h)+(type.end×>⟜«˘h)           # find start and end bars
    #h↩h⌈type.mid×«n                                   # find mid bars that have children
    #h↩h⌊type.vert                                     # clamp to vertical bar if both start and end

    ##•Show h⌈n
    {•Out ⊢◶" ○─┬├┐│"¨𝕩}˘h⌈n
  } ¨⍷ r
}

Draw p
