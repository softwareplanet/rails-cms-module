module Cms
  #
  # Common constants
  #
  NEWLINE =  "\n"

  ########################## ########################### ####################################### #############
                ############ ############## ############ ########################## ############
                             ############## ############ ##########################
                ############ ############## ############ ########################## ############
  ########################## ########################### ####################################### #############

  SOURCE_FOLDER = "data_source"
  SOURCE_FOLDERS = {
      SourceType::CSS       => "app/assets/stylesheets/custom/",
      SourceType::IMAGE     => "public/img/storage/",
      SourceType::LAYOUT    => "#{SOURCE_FOLDER}/layouts/",
      SourceType::CONTENT   => "#{SOURCE_FOLDER}/contents/",
      SourceType::HIDDEN_LAYOUT   => "#{SOURCE_FOLDER}/hidden_layouts/",
      SourceType::SEO       => "#{SOURCE_FOLDER}/seotags/",
      SourceType::UNDEFINED => "#{SOURCE_FOLDER}/others/",
      SourceType::COMPILED => "#{SOURCE_FOLDER}/compiled/",
  }

  TEST_SOURCE_FOLDER = "data_source_test"
  TEST_SOURCE_FOLDERS = {
      SourceType::CSS       => "#{TEST_SOURCE_FOLDER}/css",
      SourceType::IMAGE     => "#{TEST_SOURCE_FOLDER}/images",
      SourceType::LAYOUT    => "#{TEST_SOURCE_FOLDER}/layouts/",
      SourceType::CONTENT   => "#{TEST_SOURCE_FOLDER}/contents/",
      SourceType::HIDDEN_LAYOUT   => "#{TEST_SOURCE_FOLDER}/hidden_layouts/",
      SourceType::SEO       => "#{TEST_SOURCE_FOLDER}/seotags/",
      SourceType::UNDEFINED => "#{TEST_SOURCE_FOLDER}/others/",
      SourceType::COMPILED =>  "#{TEST_SOURCE_FOLDER}/compiled/"
  }

  SOURCE_TYPE_EXTENSIONS = {
      SourceType::CSS       => "scss",
      SourceType::IMAGE     => "*",       # * - file extension gets from the source file extension
      SourceType::LAYOUT    => "",
      SourceType::HIDDEN_LAYOUT => "",
      SourceType::CONTENT   => "",
      SourceType::SEO       => "",
      SourceType::UNDEFINED => "",
      SourceType::COMPILED => ""
  }

  # use it for file name decorations:
  #                                  ID_PREFIX + type_integer + ID_DIVIDER + source_name       < for simple source
  #                     target_type_integer + TARGET_DIVIDER + target_name + extension         < for  attached sources
  ID_PREFIX = 'pre'
  ID_DIVIDER = '-id-'
  TARGET_DIVIDER = '-tar-'
  CUSTOM_SCSS_FOLDER = "custom/"

end