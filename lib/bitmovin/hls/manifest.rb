class Bitmovin::HLS::Manifest < Bitmovin::Object
  route "encoding/manifests/hls"

  param :encoding_id
  param :output_id
  param :output_path

  option :manifest_name, default: "playlist.m3u8"

  class << self
    def find(id)
      response = Bitmovin.client.get("encoding/manifests/hls/#{id}")

      if response["status"] == "ERROR"
        raise Bitmovin::Error.new(response["data"]["message"])
      end

      result = response["data"]["result"]

      # Convert keys into snake-case symbols
      result = Hash[result.map { |k, v| [k.to_s.underscore.to_sym, v] }]

      return new(result)
    end
  end

  def build_stream(muxing_id:, stream_id:, uri:, segment_path:)
    Bitmovin::HLS::VariantStream.new(manifest_id: @id, encoding_id: @encoding_id, muxing_id: muxing_id, stream_id: stream_id, segment_path: segment_path, uri: uri)
  end

  def build_audio_stream(group_id:, language: "en", name:, default: false, segment_path:, stream_id:, muxing_id:, uri:, characteristics: [])
    Bitmovin::HLS::Audio.new(manifest_id: @id, group_id: group_id, language: language, name: name, default: default, segment_path: segment_path, encoding_id: @encoding_id, stream_id: stream_id, muxing_id: muxing_id, uri: uri, characteristics: characteristics)
  end

  def self.start!(manifest_id)
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

    response = Bitmovin.client.post("encoding/manifests/hls/#{manifest_id}/start", data: payload)

    if response["status"] == "ERROR"
      raise Bitmovin::Error.new(response["data"]["message"])
    end

    id = response["data"]["result"]["id"]
  end

  def start!
    Bitmovin::HLS::Manifest.start!(@id)
  end

protected

  def build_payload
    {
      encodingId: self.encoding_id,
      manifestName: self.manifest_name,
      outputs: [
        {
          outputId: self.output_id,
          outputPath: self.output_path,
        }
      ],
    }
  end
end