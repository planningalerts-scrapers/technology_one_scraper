# frozen_string_literal: true

require "technology_one_scraper/version"
require "technology_one_scraper/authority/blacktown"
require "technology_one_scraper/authority/sutherland"
require "technology_one_scraper/authority/tamworth"
require "technology_one_scraper/authority/wagga"
require "technology_one_scraper/authority/wyndham"
require "technology_one_scraper/postback"
require "technology_one_scraper/table"
require "technology_one_scraper/page/detail"
require "technology_one_scraper/page/index"

require "scraperwiki"

# Scrape the technology one system
module TechnologyOneScraper
  def self.scrape_and_save(authority)
    case authority
    when :blacktown
      Authority::Blacktown.scrape_and_save
    when :cockburn
      scrape_and_save_period(
        "https://ecouncil.cockburn.wa.gov.au/eProperty",
        "TM"
      )
    when :fremantle
      TechnologyOneScraper.scrape_period(
        "https://eservices.fremantle.wa.gov.au/ePropertyPROD",
        "L28"
      ) do |record|
        # TODO: Make the search ignore these rather than filtering them out here
        # Selects planning applications only
        if record["council_reference"].start_with?("DA", "LL", "VA", "WAPC", "ET", "PW")
          TechnologyOneScraper.save(record)
        end
      end
    when :kuringgai
      TechnologyOneScraper.scrape_and_save_period(
        "https://eservices.kmc.nsw.gov.au/T1ePropertyProd",
        "TM",
        "KC_WEBGUEST"
      )
    when :lithgow
      TechnologyOneScraper.scrape_and_save_period(
        "https://eservices.lithgow.nsw.gov.au/ePropertyProd",
        "L14"
      )
    when :manningham
      TechnologyOneScraper.scrape_and_save_period(
        "https://eproclaim.manningham.vic.gov.au/eProperty",
        "TM"
      )
    when :marrickville
      TechnologyOneScraper.scrape_and_save_period(
        "https://eproperty.marrickville.nsw.gov.au/eServices",
        "L14",
        "MC.P1.WEBGUEST"
      )
    when :noosa
      TechnologyOneScraper.scrape_and_save_period(
        "https://noo-web.t1cloud.com/T1PRDefault/WebApps/eProperty",
        "TM"
      )
    when :port_adelaide
      TechnologyOneScraper.scrape_period(
        "https://ecouncil.portenf.sa.gov.au/T1PRWebPROD/eProperty",
        "L7",
        "PAE.P1.WEBGUEST"
      ) do |record|
        # selects planning applications only
        TechnologyOneScraper.save(record) if record["council_reference"].start_with?("040")
      end
    when :ryde
      TechnologyOneScraper.scrape_and_save_period(
        "https://eservices.ryde.nsw.gov.au/T1PRProd/WebApps/eProperty",
        "TM",
        "COR.P1.WEBGUEST"
      )
    when :sutherland
      Authority::Sutherland.scrape_and_save
    when :tamworth
      Authority::Tamworth.scrape_and_save
    when :wagga
      Authority::Wagga.scrape_and_save
    when :wyndham
      Authority::Wyndham.scrape_and_save
    else
      raise "Unexpected authority: #{authority}"
    end
  end

  def self.save(record)
    log(record)
    ScraperWiki.save_sqlite(["council_reference"], record)
  end

  def self.log(record)
    puts "Saving record " + record["council_reference"] + ", " + record["address"]
  end

  # TODO: Instead of relying on hardcoded periods add support for general date ranges
  def self.url_period(base_url, period, webguest = "P1.WEBGUEST")
    params = {
      "Field" => "S",
      "Period" => period,
      "r" => webguest,
      "f" => "$P1.ETR.SEARCH.S#{period}"
    }
    "#{base_url}/P1/eTrack/eTrackApplicationSearchResults.aspx?#{params.to_query}"
  end

  def self.scrape_period(base_url, period, webguest = "P1.WEBGUEST")
    url = TechnologyOneScraper.url_period(base_url, period, webguest)

    agent = Mechanize.new
    # TODO: Get rid of this extra agent
    agent_detail_page = Mechanize.new

    page = agent.get(url)

    while page
      Page::Index.scrape(page, webguest) do |record|
        if record[:council_reference].nil? ||
           record[:address].nil? ||
           record[:description].nil? ||
           record[:date_received].nil?
          # We need more information. We can get this from the detail page
          detail_page = agent_detail_page.get(record[:info_url])
          record_detail = Page::Detail.scrape(detail_page)
          record = record.merge(record_detail)
          # TODO: Check that we have enough now
        end

        yield(
          "council_reference" => record[:council_reference],
          "address" => record[:address],
          "description" => record[:description],
          "info_url" => record[:info_url],
          "date_scraped" => Date.today.to_s,
          "date_received" => record[:date_received]
        )
      end
      page = Page::Index.next(page)
    end
  end

  def self.scrape_and_save_period(base_url, period, webguest = "P1.WEBGUEST")
    scrape_period(base_url, period, webguest) do |record|
      TechnologyOneScraper.save(record)
    end
  end
end
