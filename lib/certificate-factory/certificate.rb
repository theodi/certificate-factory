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
      response = post
      if response["success"] == "pending"
        @dataset_url = response["dataset_url"]
        {
          success: "pending",
          documentation_url: @url,
          dataset_url: @dataset_url
        }
      else
        {
          success: "false",
          published: "false",
          documentation_url: @url,
          error: get_error(response)
        }
      end
    end

    def result
      if @dataset_url
        result = get_result(@dataset_url)
        {
          success: result["success"],
          published: result["published"],
          documentation_url: @url,
          certificate_url: result["certificate_url"],
          user: result["owner_email"]
        }
      else
        response = generate
        if @dataset_url
          self.result
        else
          response
        end
      end
    end

    def post
      self.class.post("/datasets", body: body)
    end

    private

      def body
        {
          "jurisdiction" => "gb",
          "create_user" => "true",
          "dataset" => {
            "documentationUrl" => @url
          }
        }.to_json
      end

      def get_result(url)
        result = self.class.get(url)
        if result["success"] == "pending"
          sleep 5
          get_result(url)
        else
          result
        end
      end

      def get_error(response)
        if response["errors"]
          response["errors"].first
        elsif response.code == 401
          "Username and / or API key not recognised"
        else
          "Unknown error"
        end
      end

  end

end
