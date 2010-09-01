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
      @output << "<HTML><head></head><body>"
      
      xml.children.each do |element|
        case element.name
          when "CoverPara"
            content = handle_para(element)
            if content.length > 0
              @output << "<p>" + content + "</p>"
            end
        end
      end
      
      @output << "</body></HTML>"
      @output.join("")
    end
    
    def handle_para xml
      output = []
      if xml.children
        xml.children.each do |element|
          case element.name
            when "Text"
              output << element.inner_text.gsub("\r", " ").gsub("\n", " ")
            when "LineStart"
              output << "<br />"
          end
        end
      end
      output.join(" ").squeeze(" ").gsub(" <br /> ", "<br />")
    end
end