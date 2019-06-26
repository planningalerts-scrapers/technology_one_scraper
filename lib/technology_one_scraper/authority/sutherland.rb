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

          TechnologyOneScraper.save(record)
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

        while page
          scrape_page(page, info_url_base)
          page = Page::Index.next(page)
        end
      end
    end
  end
end
