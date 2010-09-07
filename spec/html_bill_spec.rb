require File.dirname(__FILE__) + '/spec_helper'

require 'hpricot'

describe "HtmlBill" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  describe '(DE Bill),' do
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
    
      it 'should not create <DIV> tags for empty Rubric elements' do
        @cover.should_not =~ /<div class="Rubric">/
      end
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
      
      it 'should create a <td> for each ScheduleNumber' do
        @arrangement.should =~ /<td>Schedule 1 —<\/td>/
        @arrangement.should =~ /<td>Schedule 2 —<\/td>/
        @arrangement.should =~ /<td>Schedule 3 —<\/td>/
      end
      
      it 'should create a <td> for each ScheduleTitle.arrangement/Text' do
        @arrangement.should =~ /<td>Classification of video games etc: supplementary provision<\/td>/
        @arrangement.should =~ /<td>Licensing of copyright and performers’ property rights<\/td>/
        @arrangement.should =~ /<td>Repeals<\/td>/
      end
      
      it 'should create a <tr> for each Part.arrangement within a Schedule.arrangement' do
        @arrangement.should =~ /<tr><td>Part 1 —<\/td> <td>Regulation of licensing bodies<\/td><\/tr>/
        @arrangement.should =~ /<tr><td>Part 2 —<\/td> <td>Performers’ property rights<\/td><\/tr>/
      end
    end

    describe 'when parsing Clauses HTML' do
      before do
        @clauses = @bill.clauses()
      end
      
      it 'should create a <DIV> with class of pageHead for each PageStart element' do
        @clauses.should =~ /<div class="pageHead" data-number="1"><\/div>/
        @clauses.should =~ /<div class="pageHead" data-number="2"><\/div>/
        @clauses.should =~ /<div class="pageHead" data-number="3"><\/div>/
        @clauses.should =~ /<div class="pageHead" data-number="51"><\/div>/
      end
      
      it 'should create a <DIV> with a class of prelim for the Prelim element' do
        @clauses.should =~ /<div class="prelim">/
      end
      
      it 'should create a <DIV> with a class of ABillTo for the ABillTo element' do
        @clauses.should =~ /<div class="ABillTo">/
      end
      
      it 'should create a <SPAN> with a class of Abt1 for the Abt1 element' do
        @clauses.should =~ /<span class="Abt1">A<\/span>/
      end
      
      it 'should create a <SPAN> with a class of Abt2 for the Abt2 element' do
        @clauses.should =~ /<span class="Abt2">Bill<\/span>/
      end
      
      it 'should create a <SPAN> with a class of Abt3 for the Abt3 element' do
        @clauses.should =~ /<span class="Abt3"><\/span>/
      end
      
      it 'should create a <SPAN> with a class of Abt4 for the Abt4 element' do
        @clauses.should =~ /<span class="Abt4">To<\/span>/
      end
      
      it 'should create a <DIV> with a class of LongTitle for the LongTitle element' do
        @clauses.should =~ /<div class="LongTitle">/
      end
      
      it 'should create a <DIV> with a class of WordsOfEnactment for the WordsOfEnactment element' do
        @clauses.should =~ /<div class="WordsOfEnactment">/
      end
      
      it 'should create a <DIV> with a class of crossheading for each CrossHeading element' do
        @clauses.should =~ /<div class="crossheading">/
      end
      
      it 'should create an <H2> tag for each CrossHeadingTitle element' do
        @clauses.should =~ /<h2>General duties of OFCOM<\/h2>/
        @clauses.should =~ /<h2>Online infringement of copyright<\/h2>/
        @clauses.should =~ /<h2>Powers in relation to internet domain registries<\/h2>/
        @clauses.should =~ /<h2>Channel Four Television Corporation<\/h2>/
        @clauses.should =~ /<h2>Independent television services<\/h2>/
        @clauses.should =~ /<h2>Independent radio services<\/h2>/
        @clauses.should =~ /<h2>Regulation of television and radio services<\/h2>/
        @clauses.should =~ /<h2>Access to electromagnetic spectrum<\/h2>/
        @clauses.should =~ /<h2>Video recordings<\/h2>/
        @clauses.should =~ /<h2>Copyright and performers’ property rights: licensing and penalties<\/h2>/
        @clauses.should =~ /<h2>Public lending right<\/h2>/
        @clauses.should =~ /<h2>General<\/h2>/
      end
      
      it 'should create named anchors for each numbered PageStart' do
        @clauses.should =~/<a name="page-1-line-1"><\/a>/
      end
      
      it 'should create a <DIV> tag for each Clause element' do
        @clauses.should =~ /<div class="clause"/
      end
      
      it 'should include the HardReference attribute and the number in Clause <DIV>s' do
        @clauses.should =~ /<div class="clause" data-number="1" data-hardreference="j712">/
      end
      
      it 'should create an <H2> for each ClauseTitle, incorporating the clause number as a <span>' do
        @clauses.should =~ /<h2><span class="clause_number">1<\/span> General duties of OFCOM<\/h2>/
        @clauses.should =~ /<h2><span class="clause_number">2<\/span> OFCOM reports on infrastructure, internet domain names etc<\/h2>/
        @clauses.should =~ /<h2><span class="clause_number">3<\/span> OFCOM reports on media content<\/h2>/
        @clauses.should =~ /<h2><span class="clause_number">4<\/span> Obligation to notify subscribers of reported infringements<\/h2>/
      end
      
      it 'should create a <DIV> tag for ClauseText' do
        @clauses.should =~ /<div class="clause_text">/
      end
      
      it 'should create a <DIV> tag for each SubSection' do
        @clauses.should =~ /<div class="subsection">/
      end
      
      it 'should create a <DIV> tag for each SubSection number' do
        @clauses.should =~ /<div class="subsection_number">(1)<\/div>/
      end
    end
  end
end