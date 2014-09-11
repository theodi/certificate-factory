$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'rspec/core/rake_task'
require 'certificate-factory'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :generate do

  task :certificate do
    if ENV['URL']
      puts CertificateFactory::Certificate.new(ENV['URL']).generate
    else
      puts "Please specify a URL to generate a certificate for"
    end
  end

  task :certificates do
    if ENV['URL']
      limit = ENV['LIMIT'].to_i || 2
      results = CertificateFactory::Factory.new(feed: ENV['URL'], limit: limit).build
      CSV.open("results.csv", "w") do |csv|
        csv << ["Success?", "Published?", "Documenation URL", "Dataset URL"]
        results.each { |r| csv << [r[:success], r[:published], r[:documentation_url], r[:dataset_url]] }
      end
      puts "#{limit} certificates generated. See results.csv for results"
    else
      puts "Please specify a URL for a feed to generate certificates for"
    end
  end

end
