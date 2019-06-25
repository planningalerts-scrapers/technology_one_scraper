require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Fremantle
      def self.scrape_index_page(page)
        page.search("tr[@class='normalRow'], tr[@class='alternateRow']").each do |row|
          cells = row.search('td')

          council_reference = cells[0].search("a").text
          yield(
            'council_reference' => council_reference,
            'address' => cells[5].search("a").text,
            'description' => cells[2].text,
            'info_url' => 'https://eservices.fremantle.wa.gov.au/ePropertyPROD/P1/eTrack/eTrackApplicationSearch.aspx?r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.ENQ',
            'date_received' => Date.parse(cells[1].text).strftime("%Y-%m-%d"),
            'date_scraped' => Date.today.to_s
          )
        end
      end

      def self.scrape_and_save
        agent = Mechanize.new
        url = "https://eservices.fremantle.wa.gov.au/ePropertyPROD/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=L7&r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.SL7"
        page = agent.get(url)

        # TODO: Add pagination support
        scrape_index_page(page) do |record|
          # TODO: Make the search ignore these rather than filtering them out here
          if record["council_reference"].start_with?("DA", "LL", "VA", "WAPC", "ET", "PW") #selects planning applications only
            TechnologyOneScraper.save(record)
          end
        end
      end
    end
  end
end
