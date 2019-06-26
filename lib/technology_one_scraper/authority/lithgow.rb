require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Lithgow
      def self.scrape_page(page, info_url_base)
        table = page.at("table.grid")
        Table.extract_table(table).each do |row|
          council_reference = row["Application Link"]
          info_url = info_url_base + council_reference
          record = {
            'council_reference' => council_reference,
            # TODO: No need to rewrite address
            'address' => row["Property Address"].gsub('  ', ', '),
            'description' => row["Description"],
            'info_url' => info_url,
            'date_scraped' => Date.today.to_s,
            # TODO: Do better date parsing
            'date_received' => Date.parse(row["Lodgement Date"]).to_s,
          }
          TechnologyOneScraper.save(record)
        end
      end

      def self.scrape_and_save
        period = 'L14'

        base_url = "https://eservices.lithgow.nsw.gov.au/ePropertyProd"
        url = "#{base_url}/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=" + period + "&r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.S" + period
        info_url_base = "#{base_url}/P1/eTrack/eTrackApplicationDetails.aspx?r=P1.WEBGUEST&f=%24P1.ETR.APPDET.VIW&ApplicationId="

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
