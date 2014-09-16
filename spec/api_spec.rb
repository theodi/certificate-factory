require 'spec_helper'

describe CertificateFactory::API do

  it "returns the correct URL for a dataset", :vcr do
    url = 'http://data.gov.uk/api/2/rest/package/nhs-england-primary-care-trusts-local-spending-data'
    api = CertificateFactory::API.new(url)

    expect(api.link).to eq('http://data.gov.uk/dataset/nhs-england-primary-care-trusts-local-spending-data')
  end

end
