# Introducing the all_todo gem


    require 'all_todo'


    s =<<EOF
    all_todo.txt
    ============

    # housework

    ## kitchen


    dishes washed *
    floor vacuumed (every week)

    ## bathroom

    floor vacuumed (every week)
    floor mopped (every week)
    bath cleaned *



    # gardening
    EOF

    all = AllTodo.new(s)

    puts all.to_px.to_xml pretty: true

Output:

<pre>
&lt;?xml version='1.0' encoding='UTF-8'?&gt;
&lt;sections&gt;
  &lt;summary&gt;
    &lt;title/&gt;
    &lt;recordx_type&gt;polyrex&lt;/recordx_type&gt;
    &lt;schema&gt;sections[title]/section[x]&lt;/schema&gt;
    &lt;format_mask&gt;["[!x]"]&lt;/format_mask&gt;
  &lt;/summary&gt;
  &lt;records&gt;
    &lt;section id='1'&gt;
      &lt;summary&gt;
        &lt;x&gt;housework  kitchen&lt;/x&gt;
        &lt;format_mask&gt;[!x]&lt;/format_mask&gt;
        &lt;schema&gt;section[x]&lt;/schema&gt;
        &lt;recordx_type&gt;polyrex&lt;/recordx_type&gt;
      &lt;/summary&gt;
      &lt;records&gt;
        &lt;section id='2'&gt;
          &lt;summary&gt;
            &lt;x&gt;dishes washed *&lt;/x&gt;
            &lt;format_mask&gt;[!x]&lt;/format_mask&gt;
            &lt;schema&gt;section[x]&lt;/schema&gt;
            &lt;recordx_type&gt;polyrex&lt;/recordx_type&gt;
          &lt;/summary&gt;
          &lt;records&gt;
            &lt;section id='3'&gt;
              &lt;summary&gt;
                &lt;x&gt;floor vacuumed (every week)&lt;/x&gt;
                &lt;format_mask&gt;[!x]&lt;/format_mask&gt;
                &lt;schema&gt;section[x]&lt;/schema&gt;
                &lt;recordx_type&gt;polyrex&lt;/recordx_type&gt;
              &lt;/summary&gt;
              &lt;records/&gt;
            &lt;/section&gt;
          &lt;/records&gt;
        &lt;/section&gt;
        &lt;section id='4'&gt;
          &lt;summary&gt;
            &lt;x&gt;bathroom&lt;/x&gt;
            &lt;format_mask&gt;[!x]&lt;/format_mask&gt;
            &lt;schema&gt;section[x]&lt;/schema&gt;
            &lt;recordx_type&gt;polyrex&lt;/recordx_type&gt;
          &lt;/summary&gt;
          &lt;records&gt;
            &lt;section id='5'&gt;
              &lt;summary&gt;
                &lt;x&gt;floor vacuumed (every week)&lt;/x&gt;
                &lt;format_mask&gt;[!x]&lt;/format_mask&gt;
                &lt;schema&gt;section[x]&lt;/schema&gt;
                &lt;recordx_type&gt;polyrex&lt;/recordx_type&gt;
              &lt;/summary&gt;
              &lt;records/&gt;
            &lt;/section&gt;
            &lt;section id='6'&gt;
              &lt;summary&gt;
                &lt;x&gt;floor mopped (every week)&lt;/x&gt;
                &lt;format_mask&gt;[!x]&lt;/format_mask&gt;
                &lt;schema&gt;section[x]&lt;/schema&gt;
                &lt;recordx_type&gt;polyrex&lt;/recordx_type&gt;
              &lt;/summary&gt;
              &lt;records/&gt;
            &lt;/section&gt;
            &lt;section id='7'&gt;
              &lt;summary&gt;
                &lt;x&gt;bath cleaned *&lt;/x&gt;
                &lt;format_mask&gt;[!x]&lt;/format_mask&gt;
                &lt;schema&gt;section[x]&lt;/schema&gt;
                &lt;recordx_type&gt;polyrex&lt;/recordx_type&gt;
              &lt;/summary&gt;
              &lt;records/&gt;
            &lt;/section&gt;
          &lt;/records&gt;
        &lt;/section&gt;
      &lt;/records&gt;
    &lt;/section&gt;
    &lt;section id='8'&gt;
      &lt;summary&gt;
        &lt;x&gt;gardening&lt;/x&gt;
        &lt;format_mask&gt;[!x]&lt;/format_mask&gt;
        &lt;schema&gt;section[x]&lt;/schema&gt;
        &lt;recordx_type&gt;polyrex&lt;/recordx_type&gt;
      &lt;/summary&gt;
      &lt;records/&gt;
    &lt;/section&gt;
  &lt;/records&gt;
&lt;/sections&gt;
</pre>

## Resources

* all_todo https://rubygems.org/gems/all_todo

all_todo todo gem polyrex gtd
