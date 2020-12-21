require('fileutils')
require('pry')
require('yaml')
require_relative('./Ligaturizer')
require_relative('./sql/JobReader')
require_relative('./sql/LockReleaser')
require_relative('./sql/ResultUploader')
require_relative('./sql/JobCleaner')

DB_CFG = YAML.load_file(ARGV[0])['db']
MAIN_CFG = YAML.load_file(ARGV[0])['main']
n_threads = MAIN_CFG['n_threads']

JOB_CLEANER = JobCleaner.new(DB_CFG)
JOB_Q = JobReader.new(DB_CFG)
JOB_RESULT_UPLOADER = ResultUploader.new(DB_CFG)
JOB_LOCK_RELEASER = LockReleaser.new(DB_CFG)

def process_font(uid, binary)
  ligaturizer = Ligaturizer.new
  ligaturized_font_binary = ligaturizer.ligaturize(binary)
  JOB_RESULT_UPLOADER.execute({ 'uid' => uid, 'payload' => ligaturized_font_binary })
rescue StandardError => e
  puts e.message
  JOB_LOCK_RELEASER.execute({ 'uid' => uid })
end

puts 'watching for fonts to process...'

loop do
  [Thread.new { JOB_CLEANER.execute },
   *(JOB_Q.execute({ 'limit' => n_threads })
   .map do |uid, binary|
       Thread.new do
         puts "processing: #{uid}"
         process_font(uid, binary)
       end
     end)]
    .each(&:join)
end
