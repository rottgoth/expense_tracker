RSpec.configure do |config|
  config.before(:suite) do
    FileUtils.mkdir_p('log')
    require 'logger'
    DB.loggers << Logger.new('log/sequel.log')

    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations')
    DB[:expenses].truncate
  end

  config.around(:example, :db) do |example|
    description = example.metadata[:full_description]
    DB.log_info("Starting example: #{description}")
    DB.transaction(rollback: :always) { example.run }
    DB.log_info("Ending example: #{description}")
  end
end