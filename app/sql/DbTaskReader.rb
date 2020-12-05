require_relative('DbWorker')
class DbSetup < DbWorker
  require 'pg'

  def do_work(conn) ## TODO: finish this
    conn.exec('SELECT * FROM test_table') do |result|
      puts 'uid|test_varchar'
      result.each do |row|
        puts "#{row['uid']}|#{row['test_varchar']}"
      end
    end
  end
end
