class Bitmovin::Dash::VideoAdaptationSet < Bitmovin::Object
  route "encoding/manifests/dash/:manifest_id/periods/:period_id/adaptationsets/video"

  param :manifest_id, exclude: true
  param :period_id, exclude: true

  option :roles, default: []

  def build_fmp4_representation(encoding_id:, muxing_id:, type: "TEMPLATE", segment_path:)
    Bitmovin::Dash::Representation::FMP4.new(
      manifest_id: self.manifest_id,
      period_id: self.period_id,
      adaptation_set_id: self.id,
      encoding_id: encoding_id,
      muxing_id: muxing_id,
      type: type,
      segment_path: segment_path
    )
  end
end