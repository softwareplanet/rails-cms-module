module Devcms
  FactoryGirl.define do
    factory :source do |source|
    end

    factory :content, :parent => :source do |content|
      content.type { SourceType::CONTENT }
      content.name { FactoryGirl.generate :content_name }
      content.data { ".content" }
    end

    factory :layout, :parent => :source do |layout|
      layout.type { SourceType::LAYOUT }
      layout.name { FactoryGirl.generate :layout_name }
      layout.data { ".layout" }
    end

    factory :css, :parent => :source do |css|
      css.type { SourceType::CSS }
      css.name { FactoryGirl.generate :css_name }
      css.data { "color: #abc;" }
    end

    sequence(:content_name) { |x| "content_#{x.to_s}" }
    sequence(:layout_name) { |x| "layout_#{x.to_s}" }
    sequence(:css_name) { |x| "css_#{x.to_s}" }
  end
end