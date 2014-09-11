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

    results = factory.build

    expect(results.count).to eq(1)
    expect(results.first[:success]).to eq(true)
    expect(results.first[:published]).to eq(true)
    expect(results.first[:documentation_url]).to eq("http://data.gov.uk/dataset/4820b7ee-e960-4d65-9bbd-bf05fdd5dd26")
    expect(results.first[:dataset_url]).to match /http:\/\/open-data-certificate.dev\/datasets\/[0-9]+/
  end

  it "creates the correct number of certificates when querying a single page", :vcr do
    stub_request(:get, "http://data.gov.uk/feeds/custom.atom")
                .to_return(body: load_fixture("feed.atom"))

    factory = CertificateFactory::Factory.new(feed: "http://data.gov.uk/feeds/custom.atom", limit: 3)

    results = factory.build

    expect(results.count).to eq(3)

    expect(results[0][:documentation_url]).to eq("http://data.gov.uk/dataset/4820b7ee-e960-4d65-9bbd-bf05fdd5dd26")
    expect(results[1][:documentation_url]).to eq("http://data.gov.uk/dataset/cae16900-ec34-47cf-adc1-fd8c20930b4f")
    expect(results[2][:documentation_url]).to eq("http://data.gov.uk/dataset/eb9bd647-7366-4fed-8368-4c7df007f95a")
  end

  it "creates the correct number of certificates going over multiple pages", :vcr do
    stub_request(:get, "http://data.gov.uk/feeds/custom.atom")
                .to_return(body: load_fixture("single-feed.atom"))
    stub_request(:get, "http://data.gov.uk/feeds/custom.atom?page=2")
                .to_return(body: load_fixture("single-feed.atom"))
    stub_request(:get, "http://data.gov.uk/feeds/custom.atom?page=3")
                .to_return(body: load_fixture("single-feed.atom"))

    factory = CertificateFactory::Factory.new(feed: "http://data.gov.uk/feeds/custom.atom?core_dataset=false&unpublished=false&license_id-is-ogl=true", limit: 3)

    results = factory.build

    expect(results.count).to eq(3)
  end

  it "stops when it gets to the end of a feed", :vcr do
    stub_request(:get, "http://data.gov.uk/feeds/custom.atom")
                .to_return(body: load_fixture("one-page.atom"))

    factory = CertificateFactory::Factory.new(feed: "http://data.gov.uk/feeds/custom.atom", limit: 5)

    results = factory.build

    expect(results.count).to eq(1)
  end

end
