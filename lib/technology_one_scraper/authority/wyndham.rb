require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Wyndham
      def self.get_table_of_applications(page)
        page.search("table#ctl00_Content_cusResultsGrid_repWebGrid_ctl00_grdWebGridTabularView")
      end

      # Returns html tree
      def self.get_table_rows(page)
        get_table_of_applications(page).search('tr')
      end

      # Returns the number of paginated links
      def self.get_page_link_number(page)
        get_table_of_applications(page).search('tr.pagerRow').search('td').last.text
      end

      def self.save_table_data(table_rows, url)
        table_tr_number = table_rows.length
        table_rows.each_with_index do |tr, index|

          #The tables come with a header tr[0] and two tr at bottom tr[21], tr[22]. This function wants to access the table data only, so we skip these header and footer rows
          if index == 0 or index == table_tr_number-1 or index == table_tr_number-2
            next
          end

          council_reference = tr.search("td")[0].inner_text
          link_to_decision = "https://eproperty.wyndham.vic.gov.au/ePropertyPROD/P1/eTrack/eTrackApplicationDetails.aspx?r=P1.WEBGUEST&f=%24P1.ETR.APPDET.VIW&ApplicationId=#{council_reference}"

          date_received_unformatted = tr.search("td")[1].inner_text
          day, month, year = date_received_unformatted.split("/")
          date_received_formatted = "#{year}-#{month}-#{day}"

          record = {
            "info_url" => link_to_decision,
            "council_reference" => council_reference,
            "date_received" => date_received_formatted,
            "description" => tr.search("td")[2].inner_text,
            "address" => tr.search("td")[3].inner_text,
            "status" => tr.search("td")[4].inner_text,
            "decision" => tr.search("td")[5].inner_text,
            "date_scraped" => Date.today.to_s
          }

          TechnologyOneScraper.save(record)
        end
      end

      def self.scrape_and_save
        url = "https://eproperty.wyndham.vic.gov.au/ePropertyPROD/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=L28&r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.SL28"
        agent = Mechanize.new

        #The initial scrape, this returns the first table of data and the number of pages to enter in form
        page = agent.get(url)
        table_rows = get_table_rows(page)
        page_link_number = get_page_link_number(page)
        save_table_data(table_rows, url)

        (2..page_link_number.to_i).each do |i|
          #We've already scraped the first page, so let's scrape the others using the aspnetForm
          #aspnetForm is some fantastic Microsoft idea... using JavaScript to fill in a form for pagination. This code completes the form.
          form_pagination_field = 'Page$i_here'.gsub('i_here', i.to_s) #eg, Page$2
          form = page.form("aspnetForm")
          form.add_field!('__EVENTARGUMENT', form_pagination_field)
          form.add_field!('__EVENTTARGET', 'ctl00$Content$cusResultsGrid$repWebGrid$ctl00$grdWebGridTabularView')
          page = agent.submit(form)

          table_rows = get_table_rows(page)
          save_table_data(table_rows, url)
        end
      end
    end
  end
end
