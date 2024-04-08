
⟨Compile⟩ ← •Import "./mustache.bqn"

•Out "=== Testing ==="

ext←".expected"‿".bqn"‿".mustache"
f ← •file.List "fixtures/"
n←{𝕩/˜¬0=⌽+`⌽«𝕩='.'}¨f
v←{∧´ext∊𝕩}¨(⊐n)⊔{𝕩/˜0=⌽+`⌽«𝕩='.'}¨f # valid suites where all ext exists

# TODO trim all lines instead of remove all whitespace
Trim←{ (<𝕩) { (>𝕩)/˜¬(>𝕩)=𝕨 }´ ⟨@+10,' '⟩ }

{
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
}¨n⊏˜⊑¨v/⊔⊐n #

•Out "✓ ok all done"


#! "<a>123</a>" ≡ "<a>{{foo}}</a>" Compile {foo⇐123}

#! "<a><b>1 2</b><b>3 4</b></a>" ≡"<a>{{#x}}<b>{{y}} {{z}}</b>{{/x}}</a>" Compile {x⇐⟨{y⇐1⋄z⇐2},{y⇐3⋄z⇐4}⟩}
#! "<a><b>1 2</b><b>3 4</b></a>" ≡"<a>{{#x}}<b>{{y}} {{z}}</b>{{/x}}</a>" Compile {x⇐⟨{z⇐2⋄y⇐1},{z⇐4⋄y⇐3}⟩} # reversed children namespace keys
#! "<a><b><c>1</c></b><b><c>2</c></b></a>" ≡"<a>{{#x}}<b>{{#y}}<c>{{z}}</c>{{/y}}</b>{{/x}}</a>" Compile {x⇐⟨{y⇐{z⇐1}}⋄{y⇐{z⇐2}}⟩}
#! "<a><b><c>1</c><c>2</c></b></a>" ≡"<a>{{#x}}<b>{{#y}}<c>{{z}}</c>{{/y}}</b>{{/x}}</a>" Compile {x⇐⟨{y⇐⟨{z⇐1},{z⇐2}⟩}⟩}


#•Out "✓ ok all done"
