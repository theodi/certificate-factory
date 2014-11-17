module CertificateFactory

  class Factory
    include HTTParty
    format :xml

    attr_reader :count

    def initialize(options)
      @url = options[:feed]
      @limit = options[:limit] || 20
      @campaign = options[:campaign]
      @count = 0
      @certificates = []
      @response = self.class.get(@url)
      @logger = options[:logger]
    end

    def build(&block)
      @limit.times do |i|
        if feed_items[i].nil?
          @url = next_page
          unless @url.nil?
            @logger.debug "feed: #{@url}" if @logger
            @response = self.class.get(@url)
            @limit = @limit - i
            build(&block)
          end
        else
          url = get_link(feed_items[i])
          yield Certificate.new(url, campaign: @campaign).generate
          @count += 1
        end
      end
    end

    def feed_items
      [response["feed"]["entry"]].flatten # In case there is only one feed item
    end

    def next_page
      response["feed"]["link"].find { |l| l["rel"] == "next" }["href"] rescue nil
    end

    def get_link(item)
      api_url = item["link"].find { |l| l["rel"] == "enclosure" }["href"]
      ckan_url(api_url)
    end

    def ckan_url(api_url)
      CertificateFactory::API.new(api_url).ckan_url
    end

    def response
      @response
    end

  end

end
