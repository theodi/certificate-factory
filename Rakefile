$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'rspec/core/rake_task'
require 'logger'
require 'csv'
require 'httparty'
require 'certificate-factory'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG
logger.formatter = proc {|level, datetime, _, msg| msg + "\n"}

namespace :generate do

  task :certificate do
    if ENV['URL']
      cert = CertificateFactory::Certificate.new(ENV['URL'])
      gen = cert.generate
      if gen[:success] == "pending"
        logger.info "pending: #{gen[:dataset_url]}"
        result = cert.result

        logger.info "published: #{result[:published]}"
        if result[:success]
          logger.info "user: #{result[:user]}"
          logger.info "certificate_url: #{result[:certificate_url]}"
        end
      else
        logger.error "#{gen[:error]} #{gen[:documentation_url]}"
        puts gen.inspect
      end
    else
      logger.error "Please specify a URL to generate a certificate for"
    end
  end

  task :certificates do
    url = ENV['URL']
    file = ENV['FILE']
    if (url || file) && (campaign = ENV['CAMPAIGN'])
      #dated_campaign = [campaign, DateTime.now.iso8601].join('-')
      # Create factory
      output = ENV.fetch("OUTPUT", "#{campaign}.csv")
      limit = ENV['LIMIT'].to_i if ENV['LIMIT']
      if url
        factory = CertificateFactory::Factory.new(feed: url, limit: limit, campaign: campaign, logger: logger)
      elsif file
        factory = CertificateFactory::CSVFactory.new(file: file, limit: limit, campaign: campaign, logger: logger)
      end
      count = 0
      CSV.open(output, "w") do |csv|
        csv << ["documentation_url", "dataset_url"]
        factory.build do |r|
          csv << r.values_at(:documentation_url, :dataset_url)
          logger.info "#{r[:success]}: #{r[:documentation_url]}"
          count += 1
        end
      end
      logger.info "#{count} certificates queued. See #{output} for results"
    else
      logger.error "Please specify a URL for a feed and a CAMPAIGN to generate certificates for"
    end
  end

  task :results do
    if path = ENV['FILE']
      if output = ENV['RESULTS']
        CSV.open(output, 'w') do |csv|
          csv << ["Success?", "Published?", "Documenation URL", "Certificate URL", "User"]
          CSV.foreach(path, :headers => :first_row) do |c|
            if dataset_url = c["dataset_url"]
              puts dataset_url
              result = CertificateFactory::Certificate.new(c['documentation_url'], :dataset_url => dataset_url).result
              csv << result.values_at(:success, :published, :documentation_url, :certificate_url, :user)
            end
          end
        end
      else
        logger.error "Please specify a RESULTS path"
      end
    else
      logger.error "Please specify a FILE to check for results from"
    end
  end

end

namespace :update do
  task :certificate do
    if ENV['URL']
      cert = CertificateFactory::Certificate.new(ENV['URL'])
      gen = cert.update
      if gen[:success] == "pending" || gen[:success] == true
        puts gen.inspect
        result = cert.result

        if result[:published]
          logger.info "published"
        end
        logger.info "user: #{result[:user]}"
        logger.info "certificate_url: #{result[:certificate_url]}"
      else
        logger.error "#{gen[:error]} #{gen[:documentation_url]}"
        puts gen.inspect
      end
    else
      logger.error "Please specify a URL to generate a certificate for"
    end
  end
end
