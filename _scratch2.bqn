
⟨Compile⟩ ← •Import "mustache.bqn" 


•Show "<a>{{#x}}{{y}}{{/x}}</a>" Compile {x⇐⟨{y⇐1},{y⇐2}⟩}

•Show "
  <a>
    {{#x}}
      <b>

        {{#y}}
          <c>{{z}}</c>
        {{/y}}

      </b>
    {{/x}}
  </a>

" Compile {
    x⇐⟨{
      y⇐⟨
        {z⇐1},
        {z⇐2}
    ⟩}
  ⟩}

•Show "
<a>
  {{#x}}
    <b>
      {{y}} {{z}}
    </b>
  {{/x}
</a>

" Compile {
  x⇐⟨
    {y⇐1⋄z⇐2},
    {y⇐3⋄z⇐4}
  ⟩
}
