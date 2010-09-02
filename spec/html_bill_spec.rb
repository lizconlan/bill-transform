require File.dirname(__FILE__) + '/spec_helper'

require 'hpricot'

describe "HtmlBill" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  describe 'when parsing the DE Bill' do
    before do
      @bill = HtmlBill.new(File.read("./data/digital_economy.xml"))
    end
  
    describe 'when initialized' do
      it 'should set the short title' do
        @bill.short_title.should == "Digital Economy Bill [HL]"
      end
    
      it 'should set the session number' do
        @bill.session.should == "54/5"
      end
    
      it 'should set the print number' do
        @bill.print_number.should == "HL Bill 1"
      end
    end

    describe 'when parsing Cover HTML' do
      before do
        @cover = @bill.cover()
      end
    
      it 'should create an <H2> tag for each CoverHeading element' do
        @cover.should =~ /<h2>EXPLANATORY NOTES<\/h2>/
        @cover.should =~ /<h2>EUROPEAN CONVENTION ON HUMAN RIGHTS<\/h2>/
      end
    
      it 'should create <P> tags for each CoverPara element' do
        @cover.should =~ /<p>Explanatory notes to the Bill, prepared by the Department for Business, Innovation/
        @cover.should =~ /<p>Lord Mandelson has made the following statement under section/
        @cover.should =~ /<p>In my view the provisions of the/
      end
    
      it 'should not create empty <P> tags' do
        @cover.should_not =~ /<p><\/p>/
      end
    
      it 'should create <BR> tags for each LineStart element within a paragraph' do
        @cover.should =~ /<p>Explanatory notes to the Bill, prepared by the Department for Business, Innovation<br \/>and Skills and the Department for/
      end
    
      it 'should create a <DIV> with class of pageHead for each PageStart element' do
        @cover.should =~ /<div class="pageHead" data-number="i"><\/div>/
      end
    
      it 'should not create <BR> tags for LineStart elements outside a paragraph' do
        @cover.should_not =~ /<\/h2><br \/><p>/
      end
    
      it 'should not create <DIV> tags for empty Rubric elements'
    end

    describe 'when parsing Arrangement HTML' do
      before do
        @arrangement = @bill.arrangement()
      end
    
      it 'should not create <BR> tags for LineStart elements outside a paragraph' do
        @arrangement.should_not =~ /<br \/>/
      end
    
      it 'should create an <H2> tag for Heading.arrangement' do
        @arrangement.should =~ /<h2>Contents<\/h2>/
      end
    
      it 'should create a <section class="arrangement_clauses"> for the Clauses.arrangement section' do
        @arrangement.should =~ /<section class="arrangement_clauses">/
      end
    
      it 'should create a table for each CrossHeading.arrangement' do
        @arrangement.should =~ /<table>.*<\/table>/
      end
    
      it 'should create a table caption for each CrossHeadingTitle.arrangement' do
        @arrangement.should =~ /<caption>General duties of OFCOM<\/caption>/
        @arrangement.should =~ /<caption>Online infringement of copyright<\/caption>/
      end
    
      it 'should create a <tr> for each Clause.arrangement' do
        @arrangement.should =~ /<tr.*<\/tr>/
      end
    
      it 'should create a <td> for each Clause.arrangement/Number' do
        @arrangement.should =~ /<td>1<\/td>/
        @arrangement.should =~ /<td>2<\/td>/
      end
    
      it 'should create a <td> for each Clause.arrangement/Text' do
        @arrangement.should =~ /<td>General duties of OFCOM<\/td>/
        @arrangement.should =~ /<td>OFCOM reports on infrastructure, internet domain names etc<\/td>/
      end
    
      it 'should include hardreference data in each tr' do
        @arrangement.should =~ /<tr data-hardreference="j151">/
        @arrangement.should =~ /<tr data-hardreference="j602As">/
      end
    
      it 'should create a <section class="arrangement_schedules"> for the Schedules.arrangement section' do
        @arrangement.should =~ /<section class="arrangement_schedules">/
      end
    
      it 'should create a <table> within the Schedules.arrangement <section> element' do
        @arrangement.should =~ /<section class="arrangement_schedules"><table>.*<\/table><\/section>/
      end
    
      it 'should create a <tr> for each Schedule.arrangement' do
        @arrangement.should =~ /<tr.*<\/tr>/
      end
    end
  end
end