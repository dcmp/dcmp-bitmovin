class Bitmovin::Muxing::BaseMuxing < Bitmovin::Object
  param :encoding_id, exclude: true
  param :output_id
  param :output_path

  option :segment_length, default: 4
  option :streams, default: []

  def initialize(attributes = {})
    super(attributes)
  end

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