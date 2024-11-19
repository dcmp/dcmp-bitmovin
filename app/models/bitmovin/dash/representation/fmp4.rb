class Bitmovin::Dash::Representation::FMP4 < Bitmovin::Object
  route "encoding/manifests/dash/:manifest_id/periods/:period_id/adaptationsets/:adaptation_set_id/representations/fmp4"

  param :manifest_id, exclude: true
  param :period_id, exclude: true
  param :adaptation_set_id, exclude: true

  param :encoding_id
  param :muxing_id
  param :type
  param :segment_path
end