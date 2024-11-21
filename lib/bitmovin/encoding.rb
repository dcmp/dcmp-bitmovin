class Bitmovin::Encoding < Bitmovin::Object
  route "encoding/encodings"

  param :name

  option :description

  class << self
    def find(id)
      response = Bitmovin.client.get("encoding/encodings/#{id}")

      if response["status"] == "ERROR"
        raise Bitmovin::Error.new(response["data"]["message"])
      end

      return response["data"]["result"]
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