class Bitmovin::Dash::Period < Bitmovin::Object
  route "encoding/manifests/dash/:manifest_id/periods"

  param :manifest_id, exclude: true

  def build_video_adaptation_set(roles: [])
    Bitmovin::Dash::VideoAdaptationSet.new(
      manifest_id: self.manifest_id,
      period_id: self.id, roles: roles
    )
  end

  def build_audio_adaptation_set(roles: [], accessibilities: [], labels: [], lang: nil)
    Bitmovin::Dash::AudioAdaptationSet.new(
      manifest_id: self.manifest_id,
      period_id: self.id,
      roles: roles,
      accessibilities: accessibilities,
      labels: labels,
      lang: lang
    )
  end

  def build_subtitle_adaptation_set(roles: [], accessibilities: [], lang:)
    Bitmovin::Dash::SubtitleAdaptationSet.new(
      manifest_id: self.manifest_id,
      period_id: self.id,
      lang: lang,
    )
  end

end
