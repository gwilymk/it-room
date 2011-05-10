require 'spec_helper'

describe BookingsController do
  describe "without authorisation" do
    it "should not allow access to the index page" do
      get :index
      response.should redirect_to(:controller => 'admin', :action => 'login')
    end
  end

  describe "with authorisation" do
    before do
      u = User.new(:name => 'Bob Builder', :username => 'bb', :access_level => 1, :password => 'asdfghjkl', :password_confirmation => 'asdfghjkl')
      u.save!

      session[:user_id] = u.id
    end

    it "should allow access to the index page" do
      get :index
      response.should be_success
      response.should render_template("layouts/application")
    end

    it "should allow the user to make a booking" do
    end

    it "should allow the user to see the bookings" do
    end

    it "should show the bookings by order of time" do
    end

    it "should return a list of avalibale rooms" do
    end

    it "should allow the user to delete bookings" do
    end
  end
end

