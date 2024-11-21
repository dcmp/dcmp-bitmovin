class Bitmovin::HLS::VariantStream < Bitmovin::Object

  param :manifest_id, exclude: true
  param :encoding_id
  param :muxing_id
  param :stream_id
  param :segment_path
  param :uri

  option :closed_captioning, default: 'NONE'

  def initialize(attributes = {})
    super(attributes)

    instance_route "encoding/manifests/hls/:manifest_id/streams"
  end
end
