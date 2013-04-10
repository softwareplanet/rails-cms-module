class Layout < ActiveFile::Base
  has_one :seo
  has_one :css
end

class Content < ActiveFile::Base
  has_one :css
end

class Seo < ActiveFile::Base
  belongs_to :layout
end

class LayoutCss < ActiveFile::Base
  belongs_to ActiveFile::Base
end


@layout = Layout.new('main')
@layout.css = Css