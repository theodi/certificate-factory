$:.unshift File.dirname(__FILE__)

require 'httparty'
require 'dotenv'

Dotenv.load

require 'certificate-factory/api'
require 'certificate-factory/certificate'
require 'certificate-factory/factory'

module CertificateFactory

end
