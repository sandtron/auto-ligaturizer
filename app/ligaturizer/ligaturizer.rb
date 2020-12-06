require 'securerandom'

class Ligaturizer
  def initialize(font_binary)
    @in_binary = font_binary
  end

  def write_binary_to_file(binary, out_file_path); end

  def read_file_to_binary(in_file_path); end

  def ligaturize_file(file_path); end

  def ligaturize
    temp_in_file_name = SecureRandom.uuid.to_s
    temp_out_file_name = "ligaturized#{temp_in_file_name}"
    write_binary_to_file(binary, temp_in_file_name)
    `docker run --rm -v $(pwd)/#{temp_in_file_path}:/input -v $(pwd):/output --user $(id -u) rfvgyhn/ligaturize`
    read_file_to_binary(temp_out_file_name)
  end
end
