require File.dirname(__FILE__) + '/spec_helper'

require 'hpricot'

describe "HtmlBill" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  before do
    @bill = HtmlBill.new(File.read("./data/digital_economy.xml"))
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
    
    it 'should create <DIV> with a class of Rubric for each Rubric element'
  end
end