
⟨Compile⟩ ← •Import "./mustache.bqn"

# TODO trim all lines instead of remove all whitespace
Trim←{ (<𝕩) { (>𝕩)/˜¬(>𝕩)=𝕨 }´ ⟨@+10,' '⟩ }
Test ← {
  𝕊 n:
    ⟨data⟩←•Import "fixtures/"∾ 𝕩 ∾ ".bqn"
    src←Trim •file.Chars "fixtures/" ∾ 𝕩 ∾ ".mustache"
    exp←Trim •file.Chars "fixtures/" ∾ 𝕩 ∾ ".expected"
    act←Trim src Compile data

    Msg ← {𝕊: 
      •Out "× Failed " ∾ n ∾ ""
      •Out "Expected: "
      •Out "    " ∾ exp  
      •Out "Actual:" 
      •Out "    " ∾ act
      •Out " "
    }
    !∘Msg⍟(1⊸≢) exp≡act

    •Out "✓ " ∾ 𝕩
}

•Out "=== Testing ==="

ext←".expected"‿".bqn"‿".mustache"
f ← •file.List "fixtures/"
n←{𝕩/˜¬0=⌽+`⌽«𝕩='.'}¨f
v←{∧´ext∊𝕩}¨(⊐n)⊔{𝕩/˜0=⌽+`⌽«𝕩='.'}¨f # valid suites where all ext exists
s←∧n⊏˜⊑¨v/⊔⊐n 
Test ¨{0≠≠𝕩}◶⟨s, {s/˜s∊𝕩}⟩ •args
•Out "  ok all done"

#! "<a>123</a>" ≡ "<a>{{foo}}</a>" Compile {foo⇐123}

