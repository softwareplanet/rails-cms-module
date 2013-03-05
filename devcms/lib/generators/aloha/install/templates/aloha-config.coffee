window.Aloha = window.Aloha || {}

Aloha.settings =
  modules: ['aloha', 'aloha/jquery']
  editables: '.editable-long-text, .editable-short-text'
  logLevels: 
    error: true
    warn: false
    info: false
    debug: false
    deprecated: false
  errorhandling: false
  sidebar:
    disabled: true
  ribbon: false
  locale: 'en'
  plugins:

    format:
      config: [  'b', 'i', 'p', 'sub', 'sup', 'del', 'title', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'pre', 'removeFormat' ]
      editables: '.editable-short-text': []

    list:
      config: [ 'ul', 'ol' ]
      editables: '.editables-short-text': []

    abbr:
      config: [ 'abbr' ]
      editables: '.editable-short-text': []

    link:
      config: [ 'a' ]
      editables: '.editable-short-text': []

      # all links that match the targetregex will get set the target
      # e.g. ^(?!.*aloha-editor.com).* matches all href except aloha-editor.com
      targetregex: '^(?!.*loo.no).*'

      # this target is set when either targetregex matches or not set
      # e.g. _blank opens all links in new window
      target: '_blank'

      onHrefChange: (obj, href, item) ->
        jQuery = Aloha.require 'aloha/jquery'
        if item
          jQuery(obj).attr 'data-name', item.name
        else
          jQuery(obj).removeAttr 'data-name'
    
    table:
      config: [ 'table' ]
      editables: '.editable-short-text': [ '' ]

    formatlesspaste:
      formatlessPasteOption : true
      strippedElements : [
        "em"
        "strong"
        "small"
        "s"
        "cite"
        "q"
        "dfn"
        "abbr"
        "time"
        "code"
        "var"
        "samp"
        "kbd"
        "sub"
        "sup"
        "i"
        "b"
        "u"
        "mark"
        "ruby"
        "rt"
        "rp"
        "bdi"
        "bdo"
        "ins"
        "del"
      ]

      'numerated-headers':
        numeratedactive: false

Aloha.onReady = -> # console.log "Aloha is ready!"
