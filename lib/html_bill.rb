require 'rubygems'
require 'hpricot'

class HtmlBill
  attr_accessor :short_title, :session, :print_number
  
  def initialize xml
    @doc = Hpricot.XML xml
    @short_title = (@doc/'Bill').attr('ShortTitle')
    @session = (@doc/'Bill').attr('SessionNumber')
    @print_number = (@doc/'Bill').attr('PrintNumber')
    @page_number = ""
    @clause = ""
    @subsection = ""
    @act_name = ""
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
            @page_number = pagenum
          when "Clauses.arrangement"
            content = handle_clauses_arrangement(element)
            @output << %Q|<section class="arrangement_clauses">#{content}</section>|
          when "Schedules.arrangement"
            content = handle_schedules_arrangement(element)
            @output << %Q|<section class="arrangement_schedules"><table>#{content}</table></section>|
          when "Prelim"
            content = handle_prelim(element)
            @output << %Q|<div class="prelim">#{content}</div>|
          when "CrossHeading"
            content = handle_crossheading(element)
            @output << %Q|<div class="crossheading">#{content}</div>|
          when "Clause"
            @output << handle_clause(element)
        end
      end
      
      @output.join("")
    end
    
    def handle_crossheading xml
      output = []
      if xml.children
        xml.children.each do |element|
          case element.name
            when "CrossHeadingTitle"
              output << %Q|<h2>#{strip_linebreaks(element.inner_text).strip}</h2>|
            when "LineStart"
              output << handle_linebreak(element, @page_number, false)
            when "Clause"
              output << handle_clause(element)
          end
        end
      end
      output.join(" ").squeeze(" ").gsub(" <br /> ", "<br />")
    end
    
    def handle_clause xml
      output = []
      @clause = (xml/'Number').first.inner_text
      content = handle_clause_content(xml)
      hardref = xml.attributes["HardReference"]
      if hardref.length > 0
        output << %Q|<div class="clause" data-number="#{@clause}" data-hardreference="#{hardref}" id="clause-#{@clause}">#{content}</div>|
      else
        output << %Q|<div class="clause" data-number="#{@clause}" id="clause-#{@clause}">#{content}</div>|
      end
      output.join(" ").squeeze(" ").gsub(" <br /> ", "<br />")
    end
    
    def handle_clause_content xml
      output = []
      if xml.children
        xml.children.each do |element|
          case element.name
            when "ClauseTitle"
              output << %Q|<h2><span class="clause_number">#{@clause}</span> #{strip_linebreaks(element.inner_text).strip}</h2>|
            when "ClauseText"
              content = handle_clause_content(element)
              output << %Q|<div class="clause_text">#{content}</div>|
            when "PageStart"
              pagenum = element.attributes["Number"]
              @output << %Q|<div class="pageHead" data-number="#{pagenum}"></div>|
              @page_number = pagenum
            when "SubSection"
              content = handle_subsection(element)
              output << %Q|<div class="subsection" id="clause-#{@clause}-subsection-#{@subsection}">#{content}</div>|
            when "Text"
              output << strip_linebreaks(element.inner_text)
            when "LineStart"
              output << handle_linebreak(element, @page_number, false)
          end
        end
      end
      output.join(" ").squeeze(" ").gsub(" <br /> ", "<br />")
    end
    
    def handle_subsection xml
      output = []
      if xml.children
        xml.children.each do |element|
          case element.name
            when "Number"
              @subsection = element.inner_text
              output << %Q|<div class="subsection_number">(#{element.inner_text})</div>|
            when "Text"
              text = strip_linebreaks(element.inner_text)
              act_name = act_name(text)
              unless act_name == ""
                @act_name = act_name
              end
              output << text
            when "LineStart"
              output << handle_linebreak(element, @page_number)
            when "Amendment"
              content = ""
              output << %Q|<div class="amendment" data-act="#{@act_name}">#{content}</div>|
          end
        end
      end
      output.join(" ").squeeze(" ").gsub(" <br /> ", "<br />")
    end
    
    def handle_prelim xml
      output = []
      if xml.children
        xml.children.each do |element|
          case element.name
            when "ABillTo"
              content = handle_prelim(element)
              output << %Q|<div class="ABillTo">#{content}</div>|
            when "Abt1"
              content = handle_prelim(element)
              output << %Q|<span class="Abt1">#{content}</span>|
            when "Abt2"
              content = handle_prelim(element)
              output << %Q|<span class="Abt2">#{content}</span>|
            when "Abt3"
              content = handle_prelim(element)
              output << %Q|<span class="Abt3">#{content}</span>|
            when "Abt4"
              content = handle_prelim(element)
              output << %Q|<span class="Abt4">#{content}</span>|
            when "LongTitle"
              content = handle_prelim(element)
              output << %Q|<div class="LongTitle">#{content}</div>|
            when "WordsOfEnactment"
              content = handle_prelim(element)
              output << %Q|<div class="WordsOfEnactment">#{content}</div>|
            when "Bpara"
              output << handle_para(element)
            when "Text"
              output << strip_linebreaks(element.inner_text)
            when "LineStart"
              output << handle_linebreak(element, @page_number)
          end
        end
      end
      output.join(" ").squeeze(" ").gsub(" <br /> ", "<br />")
    end
    
    def handle_para xml
      output = []
      if xml.children
        xml.children.each do |element|
          case element.name
            when "Text"
              output << strip_linebreaks(element.inner_text)
            when "LineStart"
              output << handle_linebreak(element, @page_number)
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
    
    def handle_linebreak xml, page_num, use_br=true
      output = []
      output << "<br />" if use_br
      if xml.attributes["Number"]
        line_num = xml.attributes["Number"]
        output << %Q|<a name="page-#{page_num}-line-#{line_num}"></a>|
      end
      output.join(" ").squeeze(" ")
    end
    
    def strip_linebreaks text
      text.gsub("\r", " ").gsub("\n", " ")
    end
    
    def act_name text
      act_name = ""
      if text =~ /((?:[A-Z][a-z]+,?\s){1,}(?:and )*(?:[A-Z][a-z]+\s)*Act \d{4})/
        act_name = $1
      end
      act_name
    end
end