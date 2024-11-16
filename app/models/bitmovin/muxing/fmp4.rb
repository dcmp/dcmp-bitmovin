class Bitmovin::Muxing::FMP4 < Bitmovin::Muxing::BaseMuxing
  param :encoding_id, exclude: true
  param :output_id
  param :output_path

  option :segment_length, default: 4
  option :streams, default: []

  def initialize(attributes = {})
    super

    instance_route "encoding/encodings/:encoding_id/muxings/fmp4"
  end
end