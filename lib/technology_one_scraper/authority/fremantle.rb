require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Fremantle
      def self.scrape_index_page(page)
        table = page.at("table.grid")
        Table.extract_table(table).each do |row|
          yield(
            'council_reference' => row["Application Link"],
            'address' => row["Formatted Address"],
            'description' => row["Description"],
            # TODO: Add a direct link to the application?
            'info_url' => 'https://eservices.fremantle.wa.gov.au/ePropertyPROD/P1/eTrack/eTrackApplicationSearch.aspx?r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.ENQ',
            # TODO: Do better date parsing
            'date_received' => Date.parse(row["Lodgement Date"]).to_s,
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
