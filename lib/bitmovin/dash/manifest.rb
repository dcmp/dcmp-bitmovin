class Bitmovin::Dash::Manifest < Bitmovin::Object
  route "encoding/manifests/dash"

  param :output_id
  param :output_path

  option :name
  option :description
  option :custom_data
  option :manifest_name, default: "manifest.mpd"

  def build_period
    Bitmovin::Dash::Period.new(manifest_id: @id)
  end

protected

  def build_payload
    {
      manifestName: self.manifest_name,
      outputs: [
        {
          outputId: self.output_id,
          outputPath: self.output_path,
        }
      ],
    }
  end
end