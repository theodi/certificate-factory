module CertificateFactory

  class Certificate
    include HTTParty

    base_uri ENV['BASE_URI']
    basic_auth ENV['ODC_USERNAME'], ENV['ODC_API_KEY']
    headers 'Content-Type' => 'application/json'
    default_timeout 120

    def initialize(url, options = {})
      @url = url
      @dataset_url = options[:dataset_url]
      @campaign = options[:campaign]
    end

    def generate
      response = post
      if response.code == 202
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
          dataset_url: response["dataset_url"],
          error: get_error(response)
        }
      end
    end

    def update
      response = post
      case response.code
      when 202
        {
          success: "pending",
          documentation_url: @url,
          dataset_url: @dataset_url
        }
      when 422
        error = get_error(response)
        if error == "Dataset already exists"
          dataset_id = response['dataset_id']
          response = self.class.post("/datasets/#{dataset_id}/certificates", body: body)
          {
            success: response['success'],
            documentation_url: @url,
            dataset_url: @dataset_url,
            error: get_error(response)
          }
        else
          {
            success: "false",
            documentation_url: @url,
            dataset_url: response['dataset_url'],
            error: error
          }
        end
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
        hash = {
          "jurisdiction" => "gb",
          "create_user" => true,
          "dataset" => {
            "documentationUrl" => @url
          }
        }
        hash['campaign'] = @campaign if @campaign
        hash.to_json
      end

      def get_result(url)
        loop do
          result = self.class.get(url)
          return result if result["success"] != "pending"
          url = result["dataset_url"]
          sleep 5
        end
      end

      def get_error(response)
        if response.code == 422
          response["errors"].first
        elsif response.code == 401
          "Username and / or API key not recognised"
        else
          "Unknown error"
        end
      end

  end

end
