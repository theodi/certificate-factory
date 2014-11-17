require 'spec_helper'

describe CertificateFactory::Factory do

  it "parses the Atom feed correctly" do
    stub_request(:get, "http://data.gov.uk/feeds/custom.atom")
                .to_return(body: load_fixture("single-feed.atom"))

    factory = CertificateFactory::Factory.new(feed: "http://data.gov.uk/feeds/custom.atom")

    feed_items = factory.feed_items

    expect(feed_items.count).to eq(1)
    expect(factory.next_page).to eq("http://data.gov.uk/feeds/custom.atom?page=2")
  end

  it "builds certificates correctly", :vcr do
    stub_request(:get, "http://data.gov.uk/feeds/custom.atom")
                .to_return(body: load_fixture("single-feed.atom"))

    factory = CertificateFactory::Factory.new(feed: "http://data.gov.uk/feeds/custom.atom", limit: 1)

    results = []
    called = 0
    factory.build do |generate|
      called += 1
      expect(generate[:success]).to eq("pending")
      expect(generate[:documentation_url]).to eq("http://data.gov.uk/dataset/cambridgeshire-county-council-management-band-pay-scales")
      expect(generate[:dataset_url]).to match(%r{http://open-data-certificate.dev/datasets/\d+\.json})
    end

    expect(called).to eq(1)
  end

  it "creates the correct number of certificates when querying a single page", :vcr do
    stub_request(:get, "http://data.gov.uk/feeds/custom.atom")
                .to_return(body: load_fixture("feed.atom"))

    factory = CertificateFactory::Factory.new(feed: "http://data.gov.uk/feeds/custom.atom", limit: 3)

    results = []
    factory.build do |result|
      results << result
    end

    expect(results.count).to eq(3)

    expect(results[0][:documentation_url]).to eq("http://data.gov.uk/dataset/cambridgeshire-county-council-management-band-pay-scales")
    expect(results[1][:documentation_url]).to eq("http://data.gov.uk/dataset/great_britain_tourism_survey")
    expect(results[2][:documentation_url]).to eq("http://data.gov.uk/dataset/childrens_centres_inspections_and_outcomes")
  end

  it "creates the correct number of certificates going over multiple pages", :vcr do
    stub_request(:get, "http://data.gov.uk/feeds/custom.atom")
                .to_return(body: load_fixture("single-feed.atom"))
    stub_request(:get, "http://data.gov.uk/feeds/custom.atom?page=2")
                .to_return(body: load_fixture("single-feed-1.atom"))
    stub_request(:get, "http://data.gov.uk/feeds/custom.atom?page=3")
                .to_return(body: load_fixture("single-feed-2.atom"))

    factory = CertificateFactory::Factory.new(feed: "http://data.gov.uk/feeds/custom.atom", limit: 3)

    results = []
    factory.build do |result|
      results << result
    end

    expect(results.count).to eq(3)
    expect(results[0][:documentation_url]).to eq("http://data.gov.uk/dataset/cambridgeshire-county-council-management-band-pay-scales")
    expect(results[1][:documentation_url]).to eq("http://data.gov.uk/dataset/national-coach-services")
    expect(results[2][:documentation_url]).to eq("http://data.gov.uk/dataset/gp_earnings_and_expenses")
  end

  it "stops when it gets to the end of a feed", :vcr do
    stub_request(:get, "http://data.gov.uk/feeds/custom.atom")
                .to_return(body: load_fixture("one-page.atom"))

    factory = CertificateFactory::Factory.new(feed: "http://data.gov.uk/feeds/custom.atom", limit: 5)

    results = []
    factory.build do |result|
      results << result
    end

    expect(results.count).to eq(1)
  end

end
