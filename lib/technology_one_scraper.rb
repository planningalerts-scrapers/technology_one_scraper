# frozen_string_literal: true

require "technology_one_scraper/version"
require "technology_one_scraper/authority/blacktown"
require "technology_one_scraper/authority/cockburn"
require "technology_one_scraper/authority/fremantle"
require "technology_one_scraper/authority/kuringgai"
require "technology_one_scraper/authority/lithgow"
require "technology_one_scraper/authority/manningham"
require "technology_one_scraper/authority/marrickville"
require "technology_one_scraper/authority/noosa"
require "technology_one_scraper/authority/port_adelaide"
require "technology_one_scraper/authority/ryde"
require "technology_one_scraper/authority/sutherland"
require "technology_one_scraper/authority/tamworth"
require "technology_one_scraper/authority/wagga"
require "technology_one_scraper/authority/wyndham"
require "technology_one_scraper/postback"
require "technology_one_scraper/table"
require "technology_one_scraper/page/index"

require "scraperwiki"

# Scrape the technology one system
module TechnologyOneScraper
  def self.scrape_and_save(authority)
    case authority
    when :blacktown
      Authority::Blacktown.scrape_and_save
    when :cockburn
      Authority::Cockburn.scrape_and_save
    when :fremantle
      Authority::Fremantle.scrape_and_save
    when :kuringgai
      Authority::Kuringgai.scrape_and_save
    when :lithgow
      Authority::Lithgow.scrape_and_save
    when :manningham
      Authority::Manningham.scrape_and_save
    when :marrickville
      Authority::Marrickville.scrape_and_save
    when :noosa
      Authority::Noosa.scrape_and_save
    when :port_adelaide
      Authority::PortAdelaide.scrape_and_save
    when :ryde
      Authority::Ryde.scrape_and_save
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

  def self.url_period(base_url, period, webguest = "P1.WEBGUEST")
    params = {
      "Field" => "S",
      "Period" => period,
      "r" => webguest,
      "f" => "$P1.ETR.SEARCH.S#{period}"
    }
    "#{base_url}/P1/eTrack/eTrackApplicationSearchResults.aspx?#{params.to_query}"
  end
end
