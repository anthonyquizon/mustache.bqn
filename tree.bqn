
Parent ⇐ { g←⊔¯1⌽𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }
Delete ⇐ { (/¬𝕨)(⊢-⍋)𝕨/𝕩 } # delete from parent vector
Leaf   ⇐ { ¬(↕≠𝕩)⍷𝕩 }
Depth  ⇐ { p←𝕩 ⋄ d←p≠(↕≠p) ⋄ { z←𝕩⊏p ⋄ d+↩z≠𝕩 ⋄ z } _Fix p ⋄ d } 
_Fix   ← {𝔽∘⊢⍟≢⟜𝔽_𝕣∘⊢⍟≢⟜𝔽𝕩}

# example:
# ○
# ├─┬─┐
# ○ ○ ○

type ← { none⇐0 ⋄ node⇐1 ⋄ horz⇐2 ⋄ mid⇐3 ⋄ start⇐4 ⋄ end⇐5 ⋄ vert⇐6 }

Draw ⇐ {
  p←𝕩 ⋄ r←{𝕩⊏p} _fix p ⋄ d←Depth 𝕩                    # r: roots. d: depth
  {
    par←@ ⋄ h←@ ⋄ n←@ ⋄ m←𝕩=r                         # init empty variables for hacking convience and mask for current root
    par↩{ (1+𝕩/m/p)⌾(𝕩⊸/) 𝕩 }˘m⊸/˘d=⌜˜↕⌈´d+1          # depth matrix to parent vector offset by 1 since null values are 0
    par↩∾˘(↕≠par) {«⍟𝕨 𝕩} ˘par                        # shift diagonal zeros to vertical line
    s←×⟜∊˘par×>⟜»˘par ⋄ e←×⟜{⌽∊⌽𝕩}˘ par×>⟜«˘par       # mark start and ends of parent horizontals

    n↩(<2)‿(<2)/par
    n↩0<{«𝕩∧2|↕≠𝕩}˘0¨⌾((2|↕≠n)⊸/) n                   # nodes by finding every second level then every second item within the level

    h↩(<2)‿(<2)/par⌈+`˘s-e                            # extend parents to horizontal with expanded padding
    h↩h∧¬{𝕩>«𝕩}˘h                                     # remove overflow hendings (ie o- nodes)
    h↩«0¨⌾((2|↕≠h)⊸/) h                               # bars on every second level and shift up
    h↩type.horz×0⊸< h                                 # set base type for bars
    h↩h⌈(type.start×>⟜»˘h)+(type.end×>⟜«˘h)           # find start and end bars
    h↩h⌈type.mid×«n                                   # find mid bars that have children
    h↩h⌊type.vert                                     # clamp to vertical bar if both start and end

    {•Out ⊢◶" ○─┬├┐│"¨𝕩}˘h⌈n                          # convert ids to characters and print
  }¨⍷r
}