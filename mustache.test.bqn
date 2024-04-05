
⟨Compile⟩ ← •Import "./mustache.bqn"

#! "<a>123</a>" ≡ "<a>{{foo}}</a>" Compile {foo⇐123}

! "<a>12</a>"≡"<a>{{#x}}{{y}}{{/x}}</a>" Compile {x⇐⟨{y⇐1},{y⇐2}⟩}
! "<a><b>1</b><b>2</b></a>" ≡"<a>{{#x}}<b>{{y}}</b>{{/x}}</a>" Compile {x⇐⟨{y⇐1},{y⇐2}⟩}
! "<a><b>1 2</b><b>3 4</b></a>" ≡"<a>{{#x}}<b>{{y}} {{z}}</b>{{/x}}</a>" Compile {x⇐⟨{y⇐1⋄z⇐2},{y⇐3⋄z⇐4}⟩}
! "<a><b>1 2</b><b>3 4</b></a>" ≡"<a>{{#x}}<b>{{y}} {{z}}</b>{{/x}}</a>" Compile {x⇐⟨{z⇐2⋄y⇐1},{z⇐4⋄y⇐3}⟩} # reversed children namespace keys
! "<a><b><c>1</c></b><b><c>2</c></b></a>" ≡"<a>{{#x}}<b>{{#y}}<c>{{z}}</c>{{/y}}</b>{{/x}}</a>" Compile {x⇐⟨{y⇐{z⇐1}}⋄{y⇐{z⇐2}}⟩}
! "<a><b><c>1</c><c>2</c></b></a>" ≡"<a>{{#x}}<b>{{#y}}<c>{{z}}</c>{{/y}}</b>{{/x}}</a>" Compile {x⇐⟨{y⇐⟨{z⇐1},{z⇐2}⟩}⟩}


•Out "✓ ok all done"
