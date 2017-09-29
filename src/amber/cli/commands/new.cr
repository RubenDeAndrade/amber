module Amber::CLI
  class_property color = true

  class MainCommand < ::Cli::Supercommand
    command "n", aliased: "new"

    class New < ::Cli::Command
      class Options
        arg "name", desc: "name of project", required: true
        string "-d", desc: "database", any_of: %w(pg mysql sqlite), default: "pg"
        string "-t", desc: "template language", any_of: %w(slang ecr), default: "slang"
        bool "--api", desc: "api", default: false
        bool "--deps", desc: "installs deps, (shards update)", default: false
        bool "--no-color", desc: "Disable colored output", default: false
      end

      class Help
        caption "# Generates a new Amber project"
      end

      def run
        puts "NEW Run"
        Amber::CLI.color = !options.no_color?
        name = File.basename(args.name)
        puts "=" * 60
        puts name
        puts "=" * 60
        template = Template.new(name, "./#{args.name}")
        template.generate("app", options)

        # Encrypts production.yml by default.
        cwd = Dir.current; Dir.cd(args.name)
        MainCommand.run ["encrypt", "production", "--noedit"]
        Dir.cd(cwd)
      end
    end
  end
end
