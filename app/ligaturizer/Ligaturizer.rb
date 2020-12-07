require 'securerandom'

class Ligaturizer
  def ligaturize_file(file_path); end

  def ligaturize(binary)
    tmp_dir = './tmp'
    temp_in_file_name = SecureRandom.uuid.to_s
    temp_out_file_name = "ligaturized#{temp_in_file_name}"
    IO.binwrite("#{tmp_dir}/#{temp_in_file_name}", binary)
    `docker run --rm -v #{tmp_dir}/#{temp_in_file_path}:/input -v #{tmp_dir} --user $(id -u) rfvgyhn/ligaturize`
    IO.binread(temp_out_file_name)
  end
end
