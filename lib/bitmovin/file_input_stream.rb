class Bitmovin::FileInputStream < Bitmovin::Object
  route "encoding/encodings/:encoding_id/input-streams/file"

  param :encoding_id, exclude: true

  param :input_id
  param :input_path
  param :file_type

  option :name
  option :description
end