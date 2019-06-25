require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Sutherland
      def self.scrape_page(page, info_url_base)
        page.search("table.grid tr.normalRow, table.grid tr.alternateRow").each do |tr|

          record = {
            'council_reference' => tr.search("td")[0].inner_text,
            'address' => tr.search("td")[5].inner_text.gsub('  ', ', '),
            'description' => tr.search("td")[2].inner_text,
            'info_url' => info_url_base + tr.search("td")[0].inner_text,
            'date_scraped' => Date.today.to_s,
            'date_received' => Date.parse(tr.search("td")[1].inner_text).to_s,
          }

          puts "Saving record " + record['council_reference'] + ", " + record['address']
      #       puts record
          ScraperWiki.save_sqlite(['council_reference'], record)
        end
      end

      # Implement a click on a link that understands stupid asp.net doPostBack
      def self.click(page, link)
        href = link["href"]
        if href =~ /javascript:__doPostBack\(\'(.*)\',\'(.*)'\)/
          event_target = $1
          event_argument = $2
          form = page.form_with(id: "aspnetForm")
          form["__EVENTTARGET"] = event_target
          form["__EVENTARGUMENT"] = event_argument
          form.submit
        else
          # TODO Just follow the link likes it's a normal link
          raise
        end
      end

      def self.scrape_and_save
        period = 'TM'

        base_url = "https://propertydevelopment.ssc.nsw.gov.au/T1PRPROD/WebApps/eproperty/P1/eTrack"
        url = "#{base_url}/eTrackApplicationSearchResults.aspx?Field=S&Period=" + period + "&Group=DA&SearchFunction=SSC.P1.ETR.SEARCH.DA&r=SSC.P1.WEBGUEST&f=SSC.ETR.SRCH.STW.DA&ResultsFunction=SSC.P1.ETR.RESULT.DA"
        info_url_base = "#{base_url}/eTrackApplicationDetails.aspx?r=SSC.P1.WEBGUEST&f=$P1.ETR.APPDET.VIW&ApplicationId="

        agent = Mechanize.new

        # Read in a page
        page = agent.get(url)
        current_page_no = 1
        next_page_link = true

        while next_page_link
          scrape_page(page, info_url_base)
          paging = page.at("table.grid tr.pagerRow")
          if paging.nil?
           next_page_link = false
          else
            next_page_link = paging.search("td a").find{|td| td.inner_text == (current_page_no + 1).to_s || (td.inner_text == '...' && (0 == current_page_no % 10))}
            if next_page_link
              current_page_no += 1
              puts "Getting page #{current_page_no}..."
              page = click(page, next_page_link)
            end
          end
        end
      end
    end
  end
end
