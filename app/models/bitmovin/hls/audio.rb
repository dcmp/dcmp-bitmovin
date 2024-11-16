class Bitmovin::HLS::Audio < Bitmovin::Object
  param :manifest_id, exclude: true
  param :group_id
  param :name
  param :segment_path
  param :encoding_id
  param :stream_id
  param :muxing_id
  param :uri

  option :language, default: "en"
  option :default, default: false
  option :characteristics, default: []

  def initialize(attributes = {})
    super(attributes)

    instance_route "encoding/manifests/hls/:manifest_id/media/audio"
  end
end