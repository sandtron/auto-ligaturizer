require 'securerandom'
require 'fileutils'

class Ligaturizer
  def extract_result_file_name(docker_result)
    docker_result.scan(%r{/.*\.ttf})[0].split('/').last
  end

  def ligaturize(binary)
    uid = SecureRandom.uuid.to_s
    tmp_dir = `echo $(pwd)/tmp/#{uid}`.strip

    FileUtils.mkdir_p(tmp_dir)

    temp_in_file_name = "#{tmp_dir}/in-font.ttf"

    File.open(temp_in_file_name, 'wb') { |io| io.write(binary) }

    docker_cmd = `echo docker run --rm -v #{temp_in_file_name}:/input -v #{tmp_dir}:/output --user $(id -u) rfvgyhn/ligaturizer`
    puts docker_cmd.to_s
    docker_result = `#{docker_cmd}`
    puts docker_result
    temp_out_file_name = "#{tmp_dir}/#{extract_result_file_name(docker_result)}"

    result = IO.binread(temp_out_file_name)

    FileUtils.rm([temp_in_file_name, temp_out_file_name])
    FileUtils.rmdir(tmp_dir)
    result
  end
end
