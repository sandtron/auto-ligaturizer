require 'securerandom'
require 'fileutils'

class Ligaturizer
  def extract_result_file_name(docker_result)
    docker_result.scan(%r{/.*\.ttf})[0].split('/').last
  end

  def ligaturize(binary)
    tmp_dir = `echo $(pwd)/tmp`.strip
    FileUtils.mkdir_p(tmp_dir)

    uid = "#{SecureRandom.uuid}.ttf"

    temp_in_file_name = "#{tmp_dir}/#{uid}"

    File.open(temp_in_file_name, 'wb') { |io| io.write(binary) }

    docker_result = `docker run --rm -v #{temp_in_file_name}:/input -v #{tmp_dir}:/output --user $(id -u) rfvgyhn/ligaturizer`

    temp_out_file_name = "#{tmp_dir}/#{extract_result_file_name(docker_result)}"

    resut_binary = IO.binread(temp_out_file_name)

    FileUtils.rm([temp_in_file_name, temp_out_file_name])

    resut_binary
  end
end
