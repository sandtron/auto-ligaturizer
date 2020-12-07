require('yaml')
require_relative('ligaturizer/LigaturizeJobReader')
require_relative('ligaturizer/Ligaturizer')
require_relative('ligaturizer/LigaturizerResultUploader')

DB_CFG = YAML.load_file(ARGV[0])['db']

to_process = LigaturizeJobReader.new(
  DB_CFG['host'],
  DB_CFG['database'],
  DB_CFG['user'],
  DB_CFG['port'],
  DB_CFG['password']
).execute

ligaturizer = Ligaturizer.new

to_process.each do |uid, binary|
  ligaturized_font_binary = ligaturizer.ligaturize(binary)
  LigaturizerResultUploader.new(
    DB_CFG['host'],
    DB_CFG['database'],
    DB_CFG['user'],
    DB_CFG['port'],
    DB_CFG['password']
  ).uid(uid).payload(ligaturized_font_binary).execute
end
