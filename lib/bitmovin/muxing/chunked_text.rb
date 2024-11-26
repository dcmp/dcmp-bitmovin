class Bitmovin::Muxing::ChunkedText < Bitmovin::Object
  route "encoding/encodings/:encoding_id/muxings/chunked-text"

  param :encoding_id, exclude: true
  param :output_id
  param :output_path

  option :segment_length, default: 4
  option :streams, default: []

protected

  def build_payload
    {
      segmentLength: self.segment_length,
      streams: self.streams,
      outputs: [
        {
          outputId: self.output_id,
          outputPath: self.output_path,
        }
      ]
    }
  end
end