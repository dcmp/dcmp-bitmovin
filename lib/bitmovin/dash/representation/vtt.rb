class Bitmovin::Dash::Representation::VTT < Bitmovin::Object
  route "encoding/manifests/dash/:manifest_id/periods/:period_id/adaptationsets/:adaptation_set_id/representations/vtt"

  param :manifest_id, exclude: true
  param :period_id, exclude: true
  param :adaptation_set_id, exclude: true

  param :vtt_url
end