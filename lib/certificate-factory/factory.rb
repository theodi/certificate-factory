module CertificateFactory

  class Factory
    include HTTParty
    format :xml

    def initialize(options)
      @url = options[:feed]
      @limit = options[:limit] || 20
      @count = 0
      @certificates = []
      @response = self.class.get(@url)
    end

    def build
      @limit.times do |i|
        if feed_items[i].nil?
          @url = next_page
          unless @url.nil?
            @limit = @limit - i
            build
          end
        else
          url = get_link(feed_items[i])
          generate(url)
        end
      end
      @certificates
    end

    def generate(url)
      @certificates << Certificate.new(url).generate
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
