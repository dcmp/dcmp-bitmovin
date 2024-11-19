class Bitmovin::Stream < Bitmovin::Object
  route "encoding/encodings/:encoding_id/streams"

  param :encoding_id
  param :input_id
  param :input_path
  param :codec_config_id

  option :selection_mode, default: "AUTO"

  def build_payload
    {
      inputStreams: [{
        inputId: input_id,
        inputPath: input_path,
        selectionMode: selection_mode,
      }],
      codecConfigId: codec_config_id,
    }
  end
end
