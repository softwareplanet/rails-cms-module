# = active_file: lightweight file system ORM
#   all rights reserved © 2000 – 2013
#
# Pestov Vitaly, skype name #{ariekdev}
# Interlink Software Development and Quality Assurance services, #{http://interlink-ua.com}
#
# Build a persistent domain model by mapping file system objects to Ruby classes. It inherits ActiveRecord-similar interface.
#

#
# == Examples:
#
=begin

   require 'base'

   class Material < ActiveFile::Base
     has_one :diamond
   end

   class Diamond < ActiveFile::Base
     belongs_to :material
     has_many :images
   end

   class Image < ActiveFile::Base
     belongs_to :diamond
   end


   d = Diamond.new("Cullinan")
   d.data = 'The Cullinan diamond is the largest gem-quality diamond ever found, at 3106.75 carat (603.35 g, 1.37 lb) rough weight.[1] About 10.5 cm (4.1 inches) long in its largest dimension, it was found January 26, 1905, in the Premier No. 2 mine, near Pretoria, South Africa.'
   d.save!

   m = Material.new("Carbonium")
   m.diamond = d
   m.save!

   search_result = Diamond.find_by_name("Cullinan")
   puts search_result.data

=end