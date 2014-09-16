module CertificateFactory

  class Certificate
    include HTTParty

    base_uri ENV['BASE_URI']
    basic_auth ENV['ODC_USERNAME'], ENV['ODC_API_KEY']
    headers 'Content-Type' => 'application/json'
    default_timeout 120

    def initialize(url)
      @url = url
    end

    def generate
      response = JSON.parse post
      {
        success: response["success"],
        published: response["published"],
        documentation_url: @url,
        dataset_url: dataset_url(response["dataset_id"]),
        user: response["owner_email"]
      }
    end

    def post
      self.class.post("/datasets", body: body)
    end

    private

      def body
        {
          "jurisdiction" => "gb",
          "dataset" => {
            "documentationUrl" => @url
          }
        }.to_json
      end

      def dataset_url(id)
        "#{self.class.base_uri}/datasets/#{id}"
      end

  end

end
