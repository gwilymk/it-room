class AddRootUserToInstall < ActiveRecord::Migration
  def self.up
    root = User.new
    root.create_new_salt

    root.update_attributes(:name => "root", :username => "root", :password => "root1234", :password_confirmation => "root1234", :access_level => 5)

    root.save
  end

  def self.down
    if user = User.find_by_name("root")
      user.delete
    end
  end
end

