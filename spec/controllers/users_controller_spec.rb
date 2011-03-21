require 'spec_helper'

describe UsersController do
  describe "without authorisation" do
    it "should not allow access to the index" do
      get :index
      response.should redirect_to(:controller => 'admin', :action => 'login')
    end

    it "should allow access to forgotten_password" do
      post :forgotten_password
      response.should redirect_to(admin_login_url)

      get :forgotten_password
      response.should be_success
    end

    it "should allow access to update_password" do
      post :update_password, {:key => 'wljfwliejfwilejf'}
      response.should be_success
    end
  end

  describe "with auth1" do
    before do
      u = User.new(:name => 'Bob Builder', :username => 'bb', :access_level => 5, :password => 'asdfghjkl', :password_confirmation => 'asdfghjkl')
      u.save!

      session[:user_id] = u.id
    end

    it "should allow access to update" do
      post :update, {:user => {:name => 'Bob the Builder'}}

      User.find_by_name('Bob the Builder').id.should == User.first.id
    end
  end

  describe "with authoriation" do
    before do
      u = User.new(:name => 'Bob Builder', :username => 'bb', :access_level => 5, :password => 'asdfghjkl', :password_confirmation => 'asdfghjkl')
      u.save!

      session[:user_id] = u.id
    end

    it "should allow acces to index" do
      get :index
      response.should be_success
    end

    describe "with some rooms" do
      before do
        ["bbbbbbb", "dddddddd", "aaaaa", "eeeeeeee", "ccccccc"].each do |name|
          User.create!(:name => name, :username => name, :access_level => 1, :password => 'asdfgh', :password_confirmation => 'asdfgh')
        end
      end

      it "should return a list in order" do
        get :index
        assigns[:users].first.username.should < assigns[:users][1].username
      end
    end
  end
end

