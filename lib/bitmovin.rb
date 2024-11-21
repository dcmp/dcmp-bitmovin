class RestClient
  def initialize(base_url, headers: {})
    @base_url = base_url
    @headers = headers
  end

  def post(path, data: nil)
    response = self.request(path, method: :post, data: data)
  end

private

  def request(path, method:, data:)
    url = "#{@base_url}/#{path}"
    response = Faraday.send(method, url, data.to_json, @headers)
    JSON.parse(response.body)
  end
end

module Bitmovin
  def self.init(api_key)
    @@api_key = api_key
    @@client = RestClient.new("https://api.bitmovin.com/v1", headers: {
      "accept": "application/json",
      "content-type": "application/json",
      "X-Api-Key": api_key
    })
  end

  def self.api_key
    @@api_key
  end

  def self.client
    @@client
  end
end