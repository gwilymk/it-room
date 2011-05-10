require 'spec_helper'

describe TermDate do
  let(:term_date) { TermDate.create!(week_start: 1, term_begin: Date.today, term_end: Date.today + 3.weeks) }

  subject do
    term_date
  end

  it { should be_valid }
  its(:term_begin) { should == Date.today }

  it "should return a default term" do
  end
  it "should retern term_date when asked for the last term" do
  end

  describe "With the term_date" do
    it "should be week 1 today" do
      TermDate.week(Date.today).should == 1
    end

    it "should be week 2 next week" do
      TermDate.week(Date.today + 1.week).should == 2
    end

    it "should have 21 days until the end of term" do
    end
  end
end
