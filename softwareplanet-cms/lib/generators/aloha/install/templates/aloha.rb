# Aloha configuration


#
# Which plugins to enable by default.
#
# Available plugins: 
#
# common/abbr               common/block              common/commands           common/format
# common/horizontalruler    common/link               common/paste              common/undo 
# common/characterpicker    common/contenthandler     common/highlighteditables common/image
# common/list               common/table              common/align
#
# extra/attributes          extra/cite                extra/profiler
# extra/draganddropfiles    extra/headerids           extra/linkbrowser
# extra/listenforcer        extra/numerated-headers   extra/ribbon
# extra/vie extra/browser   extra/comments            extra/formatlesspaste   
# extra/hints               extra/linkchecker         extra/metaview          
# extra/toc

Aloha::Rails.default_plugins = %w(common/format common/list common/link common/block common/undo common/contenthandler common/paste)
