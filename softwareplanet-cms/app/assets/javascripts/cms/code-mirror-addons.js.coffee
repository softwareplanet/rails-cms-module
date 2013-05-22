# Because sometimes you need to style the cursor's line.
#
# Adds an option 'styleActiveLine' which, when enabled, gives the
# active line's wrapping <div> the CSS class "CodeMirror-activeline",
# and gives its background <div> the class "CodeMirror-activeline-background".
(->
  clearActiveLine = (cm) ->
    if "_activeLine" of cm
      cm.removeLineClass cm._activeLine, "wrap", WRAP_CLASS
      cm.removeLineClass cm._activeLine, "background", BACK_CLASS
  updateActiveLine = (cm) ->
    line = cm.getLineHandle(cm.getCursor().line)
    return  if cm._activeLine is line
    clearActiveLine cm
    cm.addLineClass line, "wrap", WRAP_CLASS
    cm.addLineClass line, "background", BACK_CLASS
    cm._activeLine = line
  "use strict"
  WRAP_CLASS = "CodeMirror-activeline"
  BACK_CLASS = "CodeMirror-activeline-background"
  CodeMirror.defineOption "styleActiveLine", false, (cm, val, old) ->
    prev = old and old isnt CodeMirror.Init
    if val and not prev
      updateActiveLine cm
      cm.on "cursorActivity", updateActiveLine
    else if not val and prev
      cm.off "cursorActivity", updateActiveLine
      clearActiveLine cm
      delete cm._activeLine

)()