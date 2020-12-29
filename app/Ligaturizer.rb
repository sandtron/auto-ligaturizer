require 'securerandom'
require 'fileutils'

class Ligaturizer
  def initialize(ligaturizer_script_path)
    @ligaturizer_script_path = ligaturizer_script_path
  end

  def ligaturize(binary)
    uid = SecureRandom.uuid.to_s
    tmp_dir = `echo $(pwd)/tmp/#{uid}`.strip

    FileUtils.mkdir_p(tmp_dir)

    temp_in_file_name = "#{tmp_dir}/in-font.ttf"
    temp_out_file_name = "#{tmp_dir}/out-font.ttf"

    File.open(temp_in_file_name, 'wb') { |io| io.write(binary) }

    # Execute ligaturizer script
    `python3 #{@ligaturizer_script_path} #{temp_in_file_name} #{temp_out_file_name}`

    result = IO.binread(temp_out_file_name)

    FileUtils.rm([temp_in_file_name, temp_out_file_name])
    FileUtils.rmdir(tmp_dir)
    result
  end
end
