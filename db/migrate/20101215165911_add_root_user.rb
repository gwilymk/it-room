class AddRootUser < ActiveRecord::Migration
  def self.up
    User.create :name => "root", :username => "root", :password => "root1234", :password_confirmation => "root1234", :access_level => 5
  end

  def self.down
    if user = User.find_by_name("root")
      user.delete
    end
  end
end

