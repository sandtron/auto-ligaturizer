require('pry')
require('yaml')
require_relative('ligaturizer/LigaturizeJobReader')
require_relative('ligaturizer/Ligaturizer')
require_relative('ligaturizer/LigaturizerResultUploader')
require 'fileutils'

DB_CFG = YAML.load_file(ARGV[0])['db']
MAIN_CFG = YAML.load_file(ARGV[0])['main']
n_threads = MAIN_CFG['n_threads']

def do_work
  to_process = LigaturizeJobReader.new(
    DB_CFG['host'],
    DB_CFG['database'],
    DB_CFG['user'],
    DB_CFG['port'],
    DB_CFG['password']
  ).execute

  ligaturizer = Ligaturizer.new

  to_process.each do |uid, binary|
    begin
      ligaturized_font_binary = ligaturizer.ligaturize(binary)
      LigaturizerResultUploader.new(
        DB_CFG['host'],
        DB_CFG['database'],
        DB_CFG['user'],
        DB_CFG['port'],
        DB_CFG['password']
      ).uid(uid).payload(ligaturized_font_binary).execute
    rescue Exception => e
      puts e.message
    end
  end
end

while true
  threads = []
  (0..n_threads).each do |_i|
    threads.push(Thread.new { do_work })
  end
  threads.each { |t| t.join }
end
