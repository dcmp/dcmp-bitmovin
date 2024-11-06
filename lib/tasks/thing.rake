
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

  class Encoding
    attr_accessor :name

    def initialize(name:)
      @name = name
    end

    def save!
      Bitmovin.client.post("encoding/encodings", data: { name: @name })
    end
  end
end

def create_encoding()
  url = "https://api.bitmovin.com/v1/encoding/encodings"

  headers = {
    "accept": "application/json",
    "content-type": "application/json",
    "X-Api-Key": "d36d4b40-997a-4a26-ab5f-91d1f8156e51"
  }

  payload = {
    "name": "The name of the title",
  }

  # Use faraday to post
  response = Faraday.post(url, payload.to_json, headers)

  json = JSON.parse(response.body)
  encoding_id = json["data"]["result"]["id"]

  puts response.body

  return encoding_id
end

def add_video_stream_to_encoding(encoding_id, input_id, input_path, config_id)
  url = "https://api.bitmovin.com/v1/encoding/encodings/#{encoding_id}/streams"

  headers = {
    "accept": "application/json",
    "content-type": "application/json",
    "X-Api-Key": "d36d4b40-997a-4a26-ab5f-91d1f8156e51"
  }

  payload = {
    inputStreams: [
      {
        selectionMode: "AUTO",
        inputId: input_id,
        inputPath: input_path,
      }
    ],
    codecConfigId: config_id,
  }

  puts "====> " + payload.to_json

  # Use faraday to post
  response = Faraday.post(url, payload.to_json, headers)

  json = JSON.parse(response.body)

  puts response.body

  return json["data"]["result"]["id"]
end

def create_default_hls_manifest(encoding_id, output_id, output_path)
  url = "https://api.bitmovin.com/v1/encoding/manifests/hls/default"

  headers = {
    "accept": "application/json",
    "content-type": "application/json",
    "X-Api-Key": "d36d4b40-997a-4a26-ab5f-91d1f8156e51"
  }

  payload = {
    encodingId: encoding_id,
    manifestName: "playlist.m3u8",
    outputs: [
      {
        outputId: output_id,
        outputPath: output_path,
      }
    ]
  }

  # Use faraday to post
  response = Faraday.post(url, payload.to_json, headers)
  json = JSON.parse(response.body)

  puts response.body

  return json["data"]["result"]["id"]
end

def create_ts_muxing(encoding_id, streams, output_id, output_path)
  url = "https://api.bitmovin.com/v1/encoding/encodings/#{encoding_id}/muxings/ts"

  headers = {
    "accept": "application/json",
    "content-type": "application/json",
    "X-Api-Key": "d36d4b40-997a-4a26-ab5f-91d1f8156e51"
  }

  payload = {
    segmentLength: 4,
    streams: streams.map { |id| { streamId: id } },
    outputs: [
      {
        outputId: output_id,
        outputPath: output_path,
      }
    ]
  }

  puts "====> " + payload.to_json

  # Use faraday to post
  response = Faraday.post(url, payload.to_json, headers)
  json = JSON.parse(response.body)

  puts response.body

  return json["data"]["result"]["id"]
end

namespace :thing do
  desc "whatever"
  task :whatever => :environment do
    Bitmovin.init("d36d4b40-997a-4a26-ab5f-91d1f8156e51")
    encoding = Bitmovin::Encoding.new(name: "Elephant")
    encoding.save!
  end

end