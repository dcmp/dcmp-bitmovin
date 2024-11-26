module Bitmovin
  class RestClient
    def initialize(base_url, headers: {})
      @base_url = base_url
      @headers = headers
    end

    def post(path, data: [])
      response = self.request(path, method: :post, data: data.to_json)
    end

    def get(path, data: [])
      response = self.request(path, method: :get, data: data)
    end

  private

    def request(path, method:, data:)
      url = "#{@base_url}/#{path}"
      response = Faraday.send(method, url, data, @headers)
      JSON.parse(response.body)
    end
  end
end