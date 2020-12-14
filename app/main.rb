require('fileutils')
require('pry')
require('yaml')
require_relative('./Ligaturizer')
require_relative('./sql/JobReader')
require_relative('./sql/LockReleaser')
require_relative('./sql/ResultUploader')

DB_CFG = YAML.load_file(ARGV[0])['db']
MAIN_CFG = YAML.load_file(ARGV[0])['main']
n_threads = MAIN_CFG['n_threads']

def do_work(job_q)
  to_process = job_q.execute

  ligaturizer = Ligaturizer.new

  to_process.each do |uid, binary|
    begin
      ligaturized_font_binary = ligaturizer.ligaturize(binary)
      ResultUploader.new(
        DB_CFG['host'],
        DB_CFG['database'],
        DB_CFG['user'],
        DB_CFG['port'],
        DB_CFG['password']
      ).uid(uid).payload(ligaturized_font_binary).execute
    rescue Exception => e
      puts e.message

      LockReleaser.new(
        DB_CFG['host'],
        DB_CFG['database'],
        DB_CFG['user'],
        DB_CFG['port'],
        DB_CFG['password']
      ).uid(uid).execute
    end
  end
end
job_q = JobReader.new(
  DB_CFG['host'],
  DB_CFG['database'],
  DB_CFG['user'],
  DB_CFG['port'],
  DB_CFG['password']
)

while true
  threads = []
  (0..n_threads).each do |_i|
    threads.push(Thread.new { do_work(job_q) })
  end
  threads.each { |t| t.join }
end