# frozen_string_literal: true

module TechnologyOneScraper
  AUTHORITIES = {
    blacktown: {
      url: "https://eservices.blacktown.nsw.gov.au/T1PRProd/WebApps/eProperty",
      period: "L28",
      webguest: "BCC.P1.WEBGUEST"
    },
    cockburn: {
      url: "https://ecouncil.cockburn.wa.gov.au/eProperty",
      period: "TM"
    },
    fremantle: {
      url: "https://eservices.fremantle.wa.gov.au/ePropertyPROD",
      period: "L28"
    },
    kuringgai: {
      url: "https://eservices.kmc.nsw.gov.au/T1ePropertyProd",
      period: "TM",
      webguest: "KC_WEBGUEST"
    },
    lithgow: {
      url: "https://eservices.lithgow.nsw.gov.au/ePropertyProd",
      period: "L14"
    },
    manningham: {
      url: "https://eproclaim.manningham.vic.gov.au/eProperty",
      period: "L28"
    },
    marrickville: {
      url: "https://eproperty.marrickville.nsw.gov.au/eServices",
      period: "L14",
      webguest: "MC.P1.WEBGUEST"
    },
    noosa: {
      url: "https://noo-web.t1cloud.com/T1PRDefault/WebApps/eProperty",
      period: "TM"
    },
    port_adelaide: {
      url: "https://ecouncil.portenf.sa.gov.au/T1PRWebPROD/eProperty",
      period: "L7",
      webguest: "PAE.P1.WEBGUEST"
    },
    ryde: {
      url: "https://eservices.ryde.nsw.gov.au/T1PRProd/WebApps/eProperty",
      period: "TM",
      webguest: "COR.P1.WEBGUEST"
    },
    sutherland: {
      url: "https://propertydevelopment.ssc.nsw.gov.au/T1PRPROD/WebApps/eproperty",
      period: "TM",
      webguest: "SSC.P1.WEBGUEST"
    },
    tamworth: {
      url: "https://eproperty.tamworth.nsw.gov.au/ePropertyProd",
      period: "TM"
    },
    wagga: {
      url: "https://eservices.wagga.nsw.gov.au/T1PRWeb/eProperty",
      period: "L14",
      webguest: "WW.P1.WEBGUEST"
    },
    wyndham: {
      url: "https://eproperty.wyndham.vic.gov.au/ePropertyPROD",
      period: "L28"
    },
    charles_sturt: {
      url: "https://eproperty.charlessturt.sa.gov.au/eProperty",
      period: "L28"
    },
    holdfast_bay: {
      url: "https://chb-web.t1cloud.com/T1PRDefault/WebApps/eProperty",
      period: "L28"
    },
    mitcham: {
      url: "https://eproperty.mitchamcouncil.sa.gov.au/T1PRProd/WebApps/eProperty",
      period: "L28"
    },
    goulburn: {
      url: "https://eservices.goulburn.nsw.gov.au/eServicesProd",
      period: "TW"
    },
    shellharbour: {
      url: "https://eservices.shellharbour.nsw.gov.au/T1PRProd/WebApps/eProperty",
      period: "L28",
      webguest: "SCC.WEBGUEST",
      # Looks like the site has an incomplete certificate chain
      disable_ssl_certificate_check: true
    }
  }.freeze
end
