# frozen_string_literal: true

require "technology_one_scraper/version"
require "technology_one_scraper/postback"
require "technology_one_scraper/table"
require "technology_one_scraper/page/detail"
require "technology_one_scraper/page/index"

require "scraperwiki"
require "mechanize"

# Scrape the technology one system
module TechnologyOneScraper
  def self.scrape_and_save(authority)
    case authority
    when :blacktown
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://eservices.blacktown.nsw.gov.au/T1PRProd/WebApps/eProperty",
        period: "L28",
        webguest: "BCC.P1.WEBGUEST"
      )
    when :cockburn
      scrape_and_save_period(
        url: "https://ecouncil.cockburn.wa.gov.au/eProperty",
        period: "TM"
      )
    when :fremantle
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://eservices.fremantle.wa.gov.au/ePropertyPROD",
        period: "L28"
      )
    when :kuringgai
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://eservices.kmc.nsw.gov.au/T1ePropertyProd",
        period: "TM",
        webguest: "KC_WEBGUEST"
      )
    when :lithgow
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://eservices.lithgow.nsw.gov.au/ePropertyProd",
        period: "L14"
      )
    when :manningham
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://eproclaim.manningham.vic.gov.au/eProperty",
        period: "TM"
      )
    when :marrickville
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://eproperty.marrickville.nsw.gov.au/eServices",
        period: "L14",
        webguest: "MC.P1.WEBGUEST"
      )
    when :noosa
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://noo-web.t1cloud.com/T1PRDefault/WebApps/eProperty",
        period: "TM"
      )
    when :port_adelaide
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://ecouncil.portenf.sa.gov.au/T1PRWebPROD/eProperty",
        period: "L7",
        webguest: "PAE.P1.WEBGUEST"
      )
    when :ryde
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://eservices.ryde.nsw.gov.au/T1PRProd/WebApps/eProperty",
        period: "TM",
        webguest: "COR.P1.WEBGUEST"
      )
    when :sutherland
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://propertydevelopment.ssc.nsw.gov.au/T1PRPROD/WebApps/eproperty",
        period: "TM",
        webguest: "SSC.P1.WEBGUEST"
      )
    when :tamworth
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://eproperty.tamworth.nsw.gov.au/ePropertyProd",
        period: "TM"
      )
    when :wagga
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://eservices.wagga.nsw.gov.au/T1PRWeb/eProperty",
        period: "L14",
        webguest: "WW.P1.WEBGUEST"
      )
    when :wyndham
      TechnologyOneScraper.scrape_and_save_period(
        url: "https://eproperty.wyndham.vic.gov.au/ePropertyPROD",
        period: "L28"
      )
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

  def self.scrape_period(url:, period:, webguest: "P1.WEBGUEST")
    agent = Mechanize.new
    # TODO: Get rid of this extra agent
    agent_detail_page = Mechanize.new

    page = agent.get(url_period(url, period, webguest))

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

  def self.scrape_and_save_period(params)
    scrape_period(params) do |record|
      TechnologyOneScraper.save(record)
    end
  end
end
