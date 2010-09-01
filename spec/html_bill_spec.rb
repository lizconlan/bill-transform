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
    
    it 'should create <DIV> with a class of Rubric for each Rubric element'
    it 'should create an <H2> tag for each CoverHeading element'
    it 'should not create <BR> tags for LineStart elements outside a paragraph'
    it 'should create a <DIV> with class of pageHeader for each PageStart element'
  end
end