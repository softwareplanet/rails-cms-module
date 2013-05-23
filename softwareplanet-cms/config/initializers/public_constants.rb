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
      SourceType::IMAGE     => "app/assets/images",
      SourceType::LAYOUT    => "#{SOURCE_FOLDER}/layouts/",
      SourceType::HEAD    => "#{SOURCE_FOLDER}/head/",
      SourceType::LAYOUT_SETTINGS    => "#{SOURCE_FOLDER}/layout_settings/",
      SourceType::CMS_SETTINGS    => "#{SOURCE_FOLDER}/cms_settings/",
      SourceType::CONTENT   => "#{SOURCE_FOLDER}/contents/",
      SourceType::ORDER   => "#{SOURCE_FOLDER}/order/",
      SourceType::SEO       => "#{SOURCE_FOLDER}/seotags/",
      SourceType::UNDEFINED => "#{SOURCE_FOLDER}/others/",
      SourceType::COMPILED => "#{SOURCE_FOLDER}/compiled/",
  }

  TEST_SOURCE_FOLDER = "data_source_test"
  TEST_SOURCE_FOLDERS = {
      SourceType::CSS       => "data_css_test/css/",
      SourceType::IMAGE     => "#{TEST_SOURCE_FOLDER}/images",
      SourceType::LAYOUT    => "#{TEST_SOURCE_FOLDER}/layouts/",
      SourceType::HEAD    => "#{TEST_SOURCE_FOLDER  }/head/",
      SourceType::LAYOUT_SETTINGS    => "#{TEST_SOURCE_FOLDER}/layout_settings/",
      SourceType::CMS_SETTINGS    => "#{TEST_SOURCE_FOLDER}/cms_settings/",
      SourceType::CONTENT   => "#{TEST_SOURCE_FOLDER}/contents/",
      SourceType::ORDER   => "#{TEST_SOURCE_FOLDER}/order/",
      SourceType::SEO       => "#{TEST_SOURCE_FOLDER}/seotags/",
      SourceType::UNDEFINED => "#{TEST_SOURCE_FOLDER}/others/",
      SourceType::COMPILED =>  "#{TEST_SOURCE_FOLDER}/compiled/"
  }

  # use it for file name decorations:
  #                                  ID_PREFIX + type_integer + ID_DIVIDER + source_name       < for simple source
  #                     target_type_integer + TARGET_DIVIDER + target_name + extension         < for  attached sources
  ID_PREFIX = 'pre'
  ID_DIVIDER = '-id-'
  TARGET_DIVIDER = '-tar-'

  # overridden folders:
  overridden_path = Source.get_cms_settings_attributes.images_path
  SOURCE_FOLDER[SourceType::IMAGE] = overridden_path unless overridden_path.nil?

end
