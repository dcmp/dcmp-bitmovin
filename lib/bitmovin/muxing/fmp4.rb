class Bitmovin::Muxing::FMP4 < Bitmovin::Object
  route "encoding/encodings/:encoding_id/muxings/fmp4"

  param :encoding_id, exclude: true
  param :output_id
  param :output_path

  option :segment_length, default: 4
  option :segment_naming
  option :segment_naming_template
  option :init_segment_name
  option :init_segment_name_template
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