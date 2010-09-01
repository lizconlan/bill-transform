require 'rubygems'
require 'hpricot'

class HtmlBill
  attr_accessor :short_title, :session, :print_number
  
  def initialize xml
    @doc = Hpricot.XML xml
    @short_title = (@doc/'Bill').attr('ShortTitle')
    @session = (@doc/'Bill').attr('SessionNumber')
    @print_number = (@doc/'Bill').attr('PrintNumber')
  end
  
  def cover
    xml = @doc.at('Cover')
    make_html(xml)
  end
  
  def arrangement
    xml = (@doc/'Arrangement')
    make_html(xml)
  end
  
  def clauses
    xml = (@doc/'Clauses')
    make_html(xml)
  end
  
  def schedules
    xml = (@doc/'Schedules')
    make_html(xml)
  end
  
  def endorsement
    xml = (@doc/'Endorsement')
    make_html(xml)
  end
  
  def clause number
  end
  
  def schedule number
  end
  
  def page number
  end
  
  def bill_html
  end
  
  private
    def make_html xml
      @output = []
      
      xml.children.each do |element|
        case element.name
          when "CoverHeading"
            @output << "<h2>" + strip_linebreaks(element.inner_text) + "</h2>"
          when "CoverPara"
            content = handle_para(element)
            if content.length > 0
              @output << "<p>" + content + "</p>"
            end
          when "PageStart"
            pagenum = element.attributes["Number"]
            @output << %Q|<div class="pageHead" data-number="#{pagenum}"></div>|
        end
      end
      
      @output.join("")
    end
    
    def handle_para xml
      output = []
      if xml.children
        xml.children.each do |element|
          case element.name
            when "Text"
              output << strip_linebreaks(element.inner_text)
            when "LineStart"
              output << "<br />"
          end
        end
      end
      output.join(" ").squeeze(" ").gsub(" <br /> ", "<br />")
    end
    
    def strip_linebreaks text
      text.gsub("\r", " ").gsub("\n", " ")
    end
end