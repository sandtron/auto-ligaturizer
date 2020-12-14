require('yaml')
require_relative('./sql/JobUploader')
require 'securerandom'

def upload_file(yaml_file, payload)
  db_cfg = YAML.load_file(yaml_file)['db']
  JobUploader.new(
    db_cfg['host'],
    db_cfg['database'],
    db_cfg['user'],
    db_cfg['port'],
    db_cfg['password']
  ).payload(IO.binread(payload))
             .uid(SecureRandom.uuid)
end

config = ARGV[0]
file_pattern = ARGV[1]

Dir.glob(file_pattern).each do |payload|
  puts "uploading #{payload}"
  upload_file(config, payload).execute
  puts "uploaded #{payload}"
end
