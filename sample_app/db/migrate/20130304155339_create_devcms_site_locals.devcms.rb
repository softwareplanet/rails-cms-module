# This migration comes from cms (originally 20121129101825)
class CreateCmsSiteLocals < ActiveRecord::Migration
  def change
    create_table :cms_site_locals do |t|
      t.string :tag_id
      t.text :text
      t.string :language
      t.timestamps
    end
  end
end
