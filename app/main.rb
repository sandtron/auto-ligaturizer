require('yaml')
require_relative('sql/DbSetup')

def create_db_setup(yaml_file)
  db_cfg = YAML.load_file(yaml_file)['db']
  DbSetup.new(
    db_cfg['host'],
    db_cfg['database'],
    db_cfg['user'],
    db_cfg['port'],
    db_cfg['password']
  )
end

create_db_setup(ARGV[0]).execute
