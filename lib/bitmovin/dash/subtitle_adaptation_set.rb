class Bitmovin::Dash::SubtitleAdaptationSet < Bitmovin::Object
  route "encoding/manifests/dash/:manifest_id/periods/:period_id/adaptationsets/subtitle"

  param :manifest_id, exclude: true
  param :period_id, exclude: true
  param :lang

  option :roles, default: []
  option :accessibilities, default: []

  def build_vtt_representation(vtt_url:)
    Bitmovin::Dash::Representation::VTT.new(
      manifest_id: self.manifest_id,
      period_id: self.period_id,
      adaptation_set_id: self.id,
      vtt_url: vtt_url
    )
  end
end