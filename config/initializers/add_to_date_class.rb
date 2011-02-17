if RUBY_VERSION == "1.8.7" # we are on heroku
  class Date
    def monday?
      self.wday == 1
    end
  end
end

