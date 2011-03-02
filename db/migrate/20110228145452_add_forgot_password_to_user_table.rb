class AddForgotPasswordToUserTable < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :forgotten_password_key
    end
  end

  def self.down
    remove_column :users, :forgotten_password_key
  end
end

