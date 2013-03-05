# This migration comes from devcms (originally 20121128132941)
class CreateDevcmsSiteLanguages < ActiveRecord::Migration
  def change
    create_table :devcms_site_languages do |t|
      t.string :name, :null => false, :uniq => true
      t.string :url, :null => false, :uniq => true

      t.timestamps
    end
  end

end
