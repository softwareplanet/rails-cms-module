# Methods:

#   parse              # <= parse source seo tags
#   default_seo        # default seo tags to string
#   get_data           # <= source seo tags to string

require 'yaml'

module Cms
    SEO_DEFINITION = [
      'title' => '',
      'keywords' => '',
      'description' => ''
    ]
    class SourceSEO
      attr_accessor *SEO_DEFINITION[0].keys

      def parse(seo_source)
        result = Source.read_seo_values(seo_source)
        SEO_DEFINITION[0].map{ |n, v|
          send("#{n}=", result[n])
        }
        self
      end

      def self.default_seo
        data = "<title>#{SEO_DEFINITION[0]['title']}</title>\n"
        data += "<meta name='keywords' content='#{SEO_DEFINITION[0]['keywords']}'/>\n"
        data += "<meta name='description' content='#{SEO_DEFINITION[0]['description']}'/>"
        data
      end

      def get_data
        data = ''
        self.instance_variables.each do |key|
          value = self.instance_variable_get(key).to_s
          key = key.to_s.delete("@")
          if key == 'title'
            data += "<title>#{value}</title>\n"
          end
          if key == 'keywords'
            data += "<meta name='keywords' content='#{value}'/>\n"
          end
          if key == 'description'
            data += "<meta name='description' content='#{value}'/>"
          end
        end
        data
      end

    end

end
