class Bitmovin::HLS::VTT < Bitmovin::Object
  route "encoding/manifests/hls/:manifest_id/media/vtt"

  param :manifest_id, exclude: true

  param :group_id
  param :name
  param :vtt_url
  param :uri

  option :language
  option :assoc_language
  option :is_default, default: false
end