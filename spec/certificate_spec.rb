require 'spec_helper'

describe CertificateFactory::Certificate do

  before(:each) do
    @url = "http://data.gov.uk/dataset/defence-infrastructure-organisation-disposals-database-house-of-commons-report"
  end

  it "generates the correct body" do
    certificate = CertificateFactory::Certificate.new(@url)

    expect(certificate.send(:body)).to eq("{\"jurisdiction\":\"gb\",\"create_user\":\"true\",\"dataset\":{\"documentationUrl\":\"http://data.gov.uk/dataset/defence-infrastructure-organisation-disposals-database-house-of-commons-report\"}}")
  end

  it "requests certificate creation", :vcr do
    certificate = CertificateFactory::Certificate.new(@url)
    result = certificate.generate

    expect(result[:success]).to eq("pending")
    expect(result[:dataset_url]).to match /http:\/\/open-data-certificate.dev\/datasets\/[0-9]+.json/
  end

  it "returns an error if dataset already exists", :vcr do
    stub_request(:post, "http://#{ENV['ODC_USERNAME']}:#{ENV['ODC_API_KEY']}@open-data-certificate.dev/datasets")
          .to_return(body: {success: "false", errors: ["Dataset already exists"]}.to_json,
                     headers: {content_type: "application/json"})

    certificate = CertificateFactory::Certificate.new(@url)

    result = certificate.generate
    expect(result[:success]).to eq("false")
    expect(result[:error]).to eq("Dataset already exists")
  end

  it "returns an error if the authentication fails" do
    stub_request(:post, "http://#{ENV['ODC_USERNAME']}:#{ENV['ODC_API_KEY']}@open-data-certificate.dev/datasets")
          .to_return(body: "", status: 401)

    certificate = CertificateFactory::Certificate.new(@url)

    result = certificate.generate
    expect(result[:success]).to eq("false")
    expect(result[:error]).to eq("Username and / or API key not recognised")
  end

  it "keeps trying for a result until it gets one", :vcr do
    certificate = CertificateFactory::Certificate.new(@url)
    dataset_url = "http://open-data-certificate.dev/datasets/1.json"

    allow(CertificateFactory::Certificate).to receive(:get)
        .and_return({"success" => "pending"}, {"success" => "pending"}, {"success" => "true"})

    result = certificate.send(:get_result, dataset_url)

    expect(CertificateFactory::Certificate).to have_received(:get).exactly(3).times
    expect(result["success"]).to eq("true")
  end

  it "requests and gets a certificate", :vcr do
    certificate = CertificateFactory::Certificate.new(@url)

    result = certificate.result

    expect(result[:success]).to eq(true)
    expect(result[:published]).to eq(true)
    expect(result[:documentation_url]).to eq(@url)
    expect(result[:dataset_url]).to match /http:\/\/open-data-certificate.dev\/datasets\/[0-9]+/
    expect(result[:user]).to eq(ENV['ODC_USERNAME'])
  end


end
