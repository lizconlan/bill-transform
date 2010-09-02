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
    xml = @doc.at('Arrangement')
    make_html(xml)
  end
  
  def clauses
    xml = @doc.at('Clauses')
    make_html(xml)
  end
  
  def schedules
    xml = @doc.at('Schedules')
    make_html(xml)
  end
  
  def endorsement
    xml = @doc.at('Endorsement')
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
          when "CoverHeading", "Heading.arrangement"
            @output << "<h2>" + strip_linebreaks(element.inner_text).strip + "</h2>"
          when "CoverPara"
            content = handle_para(element)
            if content.length > 0
              @output << "<p>" + content + "</p>"
            end
          when "PageStart"
            pagenum = element.attributes["Number"]
            @output << %Q|<div class="pageHead" data-number="#{pagenum}"></div>|
          when "Clauses.arrangement"
            content = handle_clauses_arrangement(element)
            @output << %Q|<section class="arrangement_clauses">#{content}</section>|
          when "Schedules.arrangement"
            content = handle_schedules_arrangement(element)
            @output << %Q|<section class="arrangement_schedules"><table>#{content}</table></section>|
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
    
    def handle_clauses_arrangement xml
      output = []
      if xml.children
        xml.children.each do |element|
          case element.name
            when "CrossHeading.arrangement"
              content = handle_clauses_arrangement(element)
              if content.length > 0
                output << "<table>" + content + "</table>"
              end
            when "CrossHeadingTitle.arrangement"
              output << "<caption>" + strip_linebreaks(element.inner_text).strip + "</caption>"
            when "Clause.arrangement"
              content = handle_clauses_arrangement(element)
              if content.length > 0
                hardref = element.attributes["HardReference"]
                if hardref.length > 0
                  output << %Q|<tr data-hardreference="#{hardref}">#{content}</tr>|
                else
                  output << "<tr>" + content + "</tr>"
                end
              end
            when "Number"
              output << "<td>" + element.inner_text.strip + "</td>"
            when "Text"
              output << "<td>" + element.inner_text.strip + "</td>"
          end
        end
      end
      output.join(" ").squeeze(" ")
    end
    
    def handle_schedules_arrangement xml
      output = []
      if xml.children
        xml.children.each do |element|
          case element.name
            when "SchedulesTitle.arrangement"
              content = element.inner_text
              if content.length > 0
                output << "<caption>" + strip_linebreaks(element.inner_text).strip + "</caption>"
              end
            when "Schedule.arrangement"
              content = handle_schedules_arrangement(element)
              parts = handle_schedule_parts_arrangement(element)
              
              hardref = element.attributes["HardReference"]
              if hardref.length > 0
                output << %Q|<tr data-hardreference="#{hardref}">#{content}</tr>|
              else
                output << "<tr>#{content}</tr>"
              end
              output << parts
            when "ScheduleNumber.arrangement"
              output << "<td>" + element.inner_text.strip + "</td>"
            when "ScheduleTitle.arrangement"
              content = (element/'Text').inner_text
              output << "<td>" + strip_linebreaks(content).strip + "</td>"
          end
        end
      end
      output.join(" ").squeeze(" ")
    end
    
    def handle_schedule_parts_arrangement xml
      output = []
      if xml.children
        xml.children.each do |element|
          case element.name
            when "Part.arrangement"
              content = handle_schedule_parts_arrangement(element)
              output << "<tr>#{content}</tr>"
            when "PartNumber.arrangement"
              output << "<td>" + element.inner_text.strip + "</td>"
            when "PartTitle.arrangement"
              content = (element/'Text').inner_text
              output << "<td>" + strip_linebreaks(content).strip + "</td>"
          end
        end
      end
      output.join(" ").squeeze(" ")
    end
    
    def strip_linebreaks text
      text.gsub("\r", " ").gsub("\n", " ")
    end
end