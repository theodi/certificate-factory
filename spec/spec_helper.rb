ENV['BASE_URI'] = "http://open-data-certificate.dev"
ENV['ODC_USERNAME'] = "api@example.com"
ENV['ODC_API_KEY'] = "Ra1v78QHDCpbu1Pq2XCJ"

require 'simplecov'
require 'simplecov-rcov'
require 'certificate-factory'
require 'pry'
require 'webmock/rspec'
require 'coveralls'
require 'vcr'

Coveralls.wear_merged!

VCR.configure do |c|
  ignore_env = %w{SHLVL RUNLEVEL GUARD_NOTIFY DRB COLUMNS USER LOGNAME LINES TERM_PROGRAM_VERSION}
  (ENV.keys-ignore_env).select{|x| x =~ /\A[A-Z_]*\Z/}.each do |key|
    c.filter_sensitive_data("<#{key}>") { ENV[key] }
  end
  c.cassette_library_dir = 'spec/cassettes'
  c.default_cassette_options = { :record => :once }
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.before(:each) do
    allow_any_instance_of(CertificateFactory::Certificate).to receive(:sleep)
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

def load_fixture(file)
  File.read( File.join( File.dirname(File.realpath(__FILE__)) , "fixtures", file ) )
end
