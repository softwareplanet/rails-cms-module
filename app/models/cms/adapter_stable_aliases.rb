module Cms
  module AdapterStableAliases

    def get_id
      get_source_id
    end

    def delete!
      drop!
    end

    module ClassMethods
      def find_by_id(id)
        get_source_by_id(id)
      end
    end
    extend ClassMethods
  end
end