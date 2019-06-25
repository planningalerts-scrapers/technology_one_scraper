require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Ryde
      def self.postback(form, target, argument)
        form['__EVENTTARGET'] = target
        form['__EVENTARGUMENT'] = argument
        form.submit
      end

      def self.scrape_and_save
        period = "TW"

        url         = 'https://eservices.ryde.nsw.gov.au/T1PRProd/WebApps/eProperty/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=' + period +'&r=COR.P1.WEBGUEST&f=$P1.ETR.SEARCH.S' + period
        info_url    = 'https://eservices.ryde.nsw.gov.au/T1PRProd/WebApps/eProperty/P1/eTrack/eTrackApplicationDetails.aspx?r=COR.P1.WEBGUEST&f=$P1.ETR.APPDET.VIW&ApplicationId='

        agent = Mechanize.new
        page = agent.get(url)

        if page.search("tr.pagerRow").empty?
          totalPages = 1
        else
          target, argument = page.search("tr.pagerRow").search("td")[-1].at('a')['href'].scan(/'([^']*)'/).flatten
          totalPages = page.search("tr.pagerRow").search("td")[-1].inner_text.to_i
        end

        (1..totalPages).each do |i|
          puts "Scraping page " + i.to_s + " of " + totalPages.to_s

          if i == 1
            page = agent.get(url)
          else
            page = postback(page.form, target, 'Page$' + i.to_s)
          end

          results = page.search("tr.normalRow, tr.alternateRow")
          results.each do |result|
            record = {
              'council_reference' => result.search("td")[0].inner_text.to_s,
              'address'           => result.search("td")[1].inner_text.to_s,
              'description'       => result.search("td")[3].inner_text.to_s,
              'info_url'          => info_url + result.search("td")[0].inner_text.sub!("/", "%2f"),
              'date_scraped'      => Date.today.to_s,
              'date_received'     => Date.parse(result.search("td")[2]).to_s
            }

            TechnologyOneScraper.save(record)
          end
        end
      end
    end
  end
end
