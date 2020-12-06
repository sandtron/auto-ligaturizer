require('yaml')
require_relative('ligaturizer/LigaturizeJobReader')

def create_db_setup(yaml_file)
  db_cfg = YAML.load_file(yaml_file)['db']
  LigaturizeJobReader.new(
    db_cfg['host'],
    db_cfg['database'],
    db_cfg['user'],
    db_cfg['port'],
    db_cfg['password']
  )
end

to_process = create_db_setup(ARGV[0]).execute
puts to_process
