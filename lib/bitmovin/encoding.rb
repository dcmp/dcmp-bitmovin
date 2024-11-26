class Bitmovin::Encoding < Bitmovin::Object
  route "encoding/encodings"

  param :name

  option :description
  option :cloud_region, default: "AUTO"
  option :type, default: "VOD"

  attr_accessor :status, :progress

  class << self
    def find(id)
      puts "Gonna get: encoding/encondings/#{id}"
      response = Bitmovin.client.get("encoding/encodings/#{id}")
      puts "Response: #{response.to_json}"

      if response["status"] == "ERROR"
        raise Bitmovin::Error.new(response["data"]["message"])
      end

      result = response["data"]["result"]

      # Convert keys into snake-case symbols
      result = Hash[result.map { |k, v| [k.to_s.underscore.to_sym, v] }]

      return new(result)
    end
  end

  def build_stream(input_id:, input_path:, codec_config_id:)
    Bitmovin::Stream.new(encoding_id: @id, input_id: input_id, input_path: input_path, codec_config_id: codec_config_id)
  end

  def build_fmp4_muxing(output_id:, output_path:, streams: [])
    Bitmovin::Muxing::FMP4.new(encoding_id: @id, streams: streams, output_id: output_id, output_path: output_path)
  end

  def build_hls_manifest(output_id:, output_path:)
    Bitmovin::HLS::Manifest.new(encoding_id: @id, output_id: output_id, output_path: output_path)
  end

  def build_dash_manifest(output_id:, output_path:)
    Bitmovin::Dash::Manifest.new(output_id: output_id, output_path: output_path)
  end

  def start!
    payload = {
      "trimming": {
        "ignoreDurationIfInputTooShort": false
      },
      "tweaks": {
        "audioVideoSyncMode": "RESYNC_AT_START_AND_END"
      },
      "encodingMode": "STANDARD",
      "manifestGenerator": "V2"
    }

    response = Bitmovin.client.post("encoding/encodings/#{@id}/start", data: payload)

    if response["status"] == "ERROR"
      raise Bitmovin::Error.new(response["data"]["message"])
    end

    id = response["data"]["result"]["id"]
  end
end