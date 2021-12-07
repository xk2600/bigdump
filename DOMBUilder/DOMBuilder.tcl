proc element 

proc {!--} comments {
  return ""
}



}



package requires TclOO

namespace eval DOMBuilder {


  source html.dtd

  oo::class element {

    variable Attributes

    constructor {} {
    }

    method attribute {attribute} {
      # add or set attribute on this element
      array set Attributes $attribute
    }
  }

  oo::class doctype {

    variable Definition
    variable Entities

    # Entity (Expression Expansion allowing easy correlation (similar to alias)
    method ENTITY {% name alias} {
      set Entities($name) $alias
    }
    # Element
    method ELEMENT {name startTag endTag content} {
    }
    # Attribute List
    method ATTLIST {name args} {

    }

    method builtin {dtd} {
      set fd [open $dtd.dtd r]
      set re {<!\([>]*\)>}
      foreach node [regexp -all -inline -- $re] {
        set args [lassign $node node]
        switch -regexp -- [string trim [lindex $node 0]] {
          {--} {
            # ignore this as it is a comment node
          }
          {ENTITY} -
          {ELEMENT} -
          {ATTLIST} {
            # parse node 
            $node {*}$args
          }
        }
      }
    }

    fetch {dtduri} {
      return -code error {::doctype::fetch not implemented yet.}
    }

    constructor { {uri {}} } {
      if {$uri != {}} {
        fetch $uri
      } else {
        builtin html
      }
      
    }
  }

  oo::class document {

    variable Document

    constructor { {doctype {html}} {script {}} } {
      lappend document {}
    }

    method singleton {name args} {
      while {[llength [set args [lassign $ars arg]]] > 0} {
        if {[string index 0 $arg] -} {
          if {[string index 1 $args] -} {

            # end options
            set args [lassign $args content]

            # fail if args isn't empty, as we've already stripped it of all options
            # and content
            if {[llength $args > 0]} {
              return -code error "wrong # args: should be $name ?options? content"
            }

            break
          }
          
          # add option
          set args [lassign $args option($arg)]
        }
      } 
    }

    method eval {
      
      return [Document]
    }

  
  !DOCTYPE html
  a
  abbr
  address
  area
  article
  aside
  audio
  b
  base
  bdi
  bdo
  blockquote
  body
  br
  button
  canvas
  caption
  cite
  code
  col
  colgroup
  data
  datalist
  dd
  del
  details
  dfn
  dialog
  div
  dl
  dt
  em
  embed
  fieldset
  figure
  footer
  form
  h1
  h2
  h3
  h4
  h5
  h6
  head
  header
  hgroup
  hr
  html
  i
  iframe
  img
  input
  ins
  kbd
  keygen
  label
  legend
  li
  link
  main
  map
  mark
  menu
  menuitem
  meta
  meter
  nav
  noscript
  object
  ol
  optgroup
  option
  output
  p
  param
  pre
  progress
  q
  rb
  rp
  rt
  rtc
  ruby
  s
  samp
  script
  section
  select
  small
  source
  span
  strong
  style
  sub
  summary
  sup
  table
  tbody
  td
  template
  textarea
  tfoot
  th
  thead
  time
  title
  tr
  track
  u
  ul
  var
  video
  wbr

}
