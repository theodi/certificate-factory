require 'spec_helper'

describe CertificateFactory::Certificate do

  before(:each) do
    @url = "http://data.gov.uk/dataset/defence-infrastructure-organisation-disposals-database-house-of-commons-report"
  end

  it "generates the correct body" do
    certificate = CertificateFactory::Certificate.new(@url)

    expect(certificate.send(:body)).to eq("{\"jurisdiction\":\"gb\",\"dataset\":{\"documentationUrl\":\"http://data.gov.uk/dataset/defence-infrastructure-organisation-disposals-database-house-of-commons-report\"}}")
  end

  it "generates a certificate" do
    stub_request(:post, "http://api%40example.com:abc123456@open-data-certificate.dev/datasets")
                .to_return(body: load_fixture("certificate.json"))

    certificate = CertificateFactory::Certificate.new(@url)
    result = certificate.generate

    expect(result[:success]).to eq(true)
    expect(result[:published]).to eq(true)
    expect(result[:documentation_url]).to eq(@url)
    expect(result[:dataset_url]).to match /http:\/\/open-data-certificate.dev\/datasets\/[0-9]+/
    expect(result[:user]).to eq(ENV['ODC_USERNAME'])
  end
end
