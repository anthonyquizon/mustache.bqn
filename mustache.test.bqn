
⟨Compile⟩ ← •Import "./mustache.bqn"

#! "<a>123</a>" ≡ "<a>{{foo}}</a>" Compile {foo⇐123}

! "<a>12</a>"≡"<a>{{#x}}{{y}}{{/x}}</a>" Compile {x⇐⟨{y⇐1},{y⇐2}⟩}
! "<a><b>1</b><b>2</b></a>" ≡"<a>{{#x}}<b>{{y}}</b>{{/x}}</a>" Compile {x⇐⟨{y⇐1},{y⇐2}⟩}

•Out "✓ ok all done"
