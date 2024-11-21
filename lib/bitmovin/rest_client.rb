module Bitmovin
  class RestClient
    def initialize(base_url, headers: {})
      @base_url = base_url
      @headers = headers
    end

    def post(path, data: nil)
      response = self.request(path, method: :post, data: data)
    end

    def get(path)
      url = "#{@base_url}/#{path}"
      response = Faraday.get(url)
      JSON.parse(response.body)
    end

  private

    def request(path, method:, data:)
      url = "#{@base_url}/#{path}"
      response = Faraday.send(method, url, data.to_json, @headers)
      JSON.parse(response.body)
    end
  end
end