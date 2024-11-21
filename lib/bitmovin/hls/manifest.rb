class Bitmovin::HLS::Manifest < Bitmovin::Object
  route "encoding/manifests/hls"

  param :encoding_id
  param :output_id
  param :output_path

  option :manifest_name, default: "playlist.m3u8"

  def build_stream(muxing_id:, stream_id:, uri:, segment_path:)
    Bitmovin::HLS::VariantStream.new(manifest_id: @id, encoding_id: @encoding_id, muxing_id: muxing_id, stream_id: stream_id, segment_path: segment_path, uri: uri)
  end

  def build_audio_stream(group_id:, language: "en", name:, default: false, segment_path:, stream_id:, muxing_id:, uri:, characteristics: [])
    Bitmovin::HLS::Audio.new(manifest_id: @id, group_id: group_id, language: language, name: name, default: default, segment_path: segment_path, encoding_id: @encoding_id, stream_id: stream_id, muxing_id: muxing_id, uri: uri, characteristics: characteristics)
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