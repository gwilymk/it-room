class AddUserLanguagePreference < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :prefered_language, :default => 'en'
    end

    User.update_all ["prefered_language = ?", "en"]
  end

  def self.down
    remove_column :users, :prefered_language
  end
end

