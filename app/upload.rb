require('yaml')
require_relative('ligaturizer/LigatureUploader')
require 'securerandom'

def upload_file(yaml_file, payload)
  db_cfg = YAML.load_file(yaml_file)['db']
  LigatureUploader.new(
    db_cfg['host'],
    db_cfg['database'],
    db_cfg['user'],
    db_cfg['port'],
    db_cfg['password']
  ).payload(payload)
                  .uid(SecureRandom.uuid)
end

config = ARGV[0]
payload = ARGV[1]

upload_file(config, payload).execute
