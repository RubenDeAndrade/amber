module Amber::CLI
  class App < Teeplate::FileTree
    directory "#{__DIR__}/app"

    @name : String
    @app : String
    @database : String
    @db_url : String
    @wait_for : String

    def initialize(@name, @database = "pg", @language = "slang", @api = false)
      @app = @api ? "api" : "app"
      @db_url = ""
      @wait_for = ""
    end

    def filter(entries)
      puts "YOYOYO"
      entries.reject { |entry| (entry.path.includes?("src/views") && !entry.path.includes?("#{@language}")) || (entry.path.includes?("src/views") && @api) }
    end
  end
end
