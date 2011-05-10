require 'spec_helper'

describe AdminController do
  describe "without authorisation" do

    it "should allow the user to login" do
    end
  end

  describe "with authorisation" do
    before do
      u = User.new(:name => 'Bob Builder', :username => 'bb', :access_level => 5, :password => 'asdfghjkl', :password_confirmation => 'asdfghjkl')
      u.save!

      session[:user_id] = u.id
    end

    it "should allow access to the auto_book page" do
      get :auto_book
      response.should be_success
      response.should render_template("layouts/application")
    end

    it "should allow for autobookings" do
    end

    it "should make some auto_books" do
    end

    it "should allow the user to logout" do
    end

    it "should allow the user to change preferences" do
    end
  end
end

