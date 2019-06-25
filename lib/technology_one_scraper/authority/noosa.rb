require 'scraperwiki'
require 'mechanize'
require 'uri'

module TechnologyOneScraper
  module Authority
    module Noosa
      def self.has_blank?(hash)
        hash.values.any?{|v| v.nil? || v.length == 0}
      end

      def self.postback(form, target, argument)
        form['__EVENTTARGET'] = target
        form['__EVENTARGUMENT'] = argument
        form.submit
      end

      def self.scrape_and_save
        period = "TW"

        url         = 'https://noo-web.t1cloud.com/T1PRDefault/WebApps/eProperty/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=' + period +'&r=P1.WEBGUEST&f=$P1.ETR.SEARCH.S' + period
        info_url    = 'https://noo-web.t1cloud.com/T1PRDefault/WebApps/eProperty/P1/eTrack/eTrackApplicationDetails.aspx?r=P1.WEBGUEST&f=$P1.ETR.APPDET.VIW&ApplicationId='

        agent = Mechanize.new
        agent_detail_page = Mechanize.new
        page = agent.get(url)

        if page.search("tr.pagerRow").empty?
          totalPages = 1
        else
          target, argument = page.search("tr.pagerRow").search("td")[-1].at('a')['href'].scan(/'([^']*)'/).flatten
          while page.search("tr.pagerRow").search("td")[-1].inner_text == '...' do
            target, argument = page.search("tr.pagerRow").search("td")[-1].at('a')['href'].scan(/'([^']*)'/).flatten
            page = postback(page.form, target, argument)
          end
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
            detail_page = agent_detail_page.get( info_url + URI::encode_www_form_component(result.search("td")[0].inner_text) )
            address = detail_page.search('td.headerColumn[contains("Address")] ~ td').inner_text

            record = {
              'council_reference' => result.search("td")[0].inner_text.to_s,
              'address'           => address,
              'description'       => result.search("td")[2].inner_text.to_s.squeeze(' '),
              'info_url'          => info_url + URI::encode_www_form_component(result.search("td")[0].inner_text),
              'date_scraped'      => Date.today.to_s,
              'date_received'     => Date.parse(result.search("td")[1]).to_s
            }

            if has_blank?(record)
              puts 'Something is blank, skipping record ' + record['council_reference']
              puts record
            else
              TechnologyOneScraper.save(record)
            end
          end
        end
      end
    end
  end
end
