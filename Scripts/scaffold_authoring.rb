#!/usr/bin/env ruby
# frozen_string_literal: true

require "erb"
require "fileutils"
require "optparse"

ROOT_DIR = File.expand_path("..", __dir__)
AUTHORING_ROOT = File.join(ROOT_DIR, "Authoring", "Scenarios")
TEMPLATE_ROOT = File.join(ROOT_DIR, "Authoring", "Templates")

class ScaffoldError < StandardError; end

class AuthoringScaffolder
  def run(argv)
    command = argv.shift
    raise ScaffoldError, usage unless command

    case command
    when "scenario"
      scaffold_scenario(argv)
    when "event"
      scaffold_event(argv)
    when "interactable"
      scaffold_interactable(argv)
    when "node"
      scaffold_node(argv)
    else
      raise ScaffoldError, "Unknown command #{command.inspect}\n\n#{usage}"
    end
  end

  private

  def scaffold_scenario(argv)
    options = {
      description: "Describe the expedition premise.",
      party_size: 3,
      starting_node_id: "base_camp",
      starting_node_name: "Base Camp",
      force: false
    }

    parser = OptionParser.new do |opts|
      opts.banner = "Usage: ./Scripts/scaffold_authoring.rb scenario <scenario_id> <title> [options]"
      opts.on("--description TEXT", "Starter scenario description") { |value| options[:description] = value }
      opts.on("--party-size N", Integer, "Initial party size (default: 3)") { |value| options[:party_size] = value }
      opts.on("--starting-node-id ID", "Starter symbolic node id") { |value| options[:starting_node_id] = value }
      opts.on("--starting-node-name NAME", "Starter node display name") { |value| options[:starting_node_name] = value }
      opts.on("--force", "Overwrite existing files") { options[:force] = true }
    end

    parser.parse!(argv)
    scenario_id = argv.shift
    title = argv.join(" ").strip

    raise ScaffoldError, parser.to_s unless scenario_id && !scenario_id.empty? && !title.empty?

    scenario_dir = File.join(AUTHORING_ROOT, scenario_id)
    FileUtils.mkdir_p(scenario_dir)
    FileUtils.mkdir_p(File.join(scenario_dir, "events"))
    FileUtils.mkdir_p(File.join(scenario_dir, "interactables"))

    locals = {
      scenario_id: scenario_id,
      title: title,
      description: options[:description],
      party_size: options[:party_size],
      starting_node_id: options[:starting_node_id],
      starting_node_name: options[:starting_node_name]
    }

    write_template("scenario.yaml.erb", File.join(scenario_dir, "scenario.yaml"), locals, force: options[:force])
    write_template("archetypes.yaml.erb", File.join(scenario_dir, "archetypes.yaml"), locals, force: options[:force])
    write_template("map.yaml.erb", File.join(scenario_dir, "map.yaml"), locals, force: options[:force])
    write_template("clocks.yaml.erb", File.join(scenario_dir, "clocks.yaml"), locals, force: options[:force])
    write_template("treasures.yaml.erb", File.join(scenario_dir, "treasures.yaml"), locals, force: options[:force])
    write_template("harm_families.yaml.erb", File.join(scenario_dir, "harm_families.yaml"), locals, force: options[:force])
    write_template("interactables.yaml.erb", File.join(scenario_dir, "interactables.yaml"), locals, force: options[:force])

    puts "Scaffolded scenario authoring at #{relative_to_root(scenario_dir)}"
    puts "Next: ./Scripts/check_authored_scenarios.sh #{scenario_id}"
  end

  def scaffold_event(argv)
    options = {
      description: "Describe when this event should fire and what it changes.",
      force: false
    }

    parser = OptionParser.new do |opts|
      opts.banner = "Usage: ./Scripts/scaffold_authoring.rb event <scenario_id> <event_id> [options]"
      opts.on("--description TEXT", "Starter event description") { |value| options[:description] = value }
      opts.on("--force", "Overwrite existing files") { options[:force] = true }
    end

    parser.parse!(argv)
    scenario_id = argv.shift
    event_id = argv.shift
    raise ScaffoldError, parser.to_s unless scenario_id && event_id

    scenario_dir = require_scenario_dir(scenario_id)
    events_dir = File.join(scenario_dir, "events")
    FileUtils.mkdir_p(events_dir)

    write_template(
      "event.yaml.erb",
      File.join(events_dir, "#{event_id}.yaml"),
      {
        event_id: event_id,
        description: options[:description]
      },
      force: options[:force]
    )

    puts "Created #{relative_to_root(File.join(events_dir, "#{event_id}.yaml"))}"
  end

  def scaffold_interactable(argv)
    options = {
      group: "opportunities",
      title: nil,
      description: "Describe what the player sees and why it matters.",
      action_type: "Study",
      force: false
    }

    parser = OptionParser.new do |opts|
      opts.banner = "Usage: ./Scripts/scaffold_authoring.rb interactable <scenario_id> <interactable_id> [options]"
      opts.on("--group NAME", "Authoring group (default: opportunities)") { |value| options[:group] = value }
      opts.on("--title TEXT", "Display title") { |value| options[:title] = value }
      opts.on("--description TEXT", "Starter description") { |value| options[:description] = value }
      opts.on("--action-type NAME", "Starter action type (default: Study)") { |value| options[:action_type] = value }
      opts.on("--force", "Overwrite existing files") { options[:force] = true }
    end

    parser.parse!(argv)
    scenario_id = argv.shift
    interactable_id = argv.shift
    raise ScaffoldError, parser.to_s unless scenario_id && interactable_id

    scenario_dir = require_scenario_dir(scenario_id)
    interactables_dir = File.join(scenario_dir, "interactables")
    FileUtils.mkdir_p(interactables_dir)

    write_template(
      "interactable.yaml.erb",
      File.join(interactables_dir, "#{interactable_id}.yaml"),
      {
        interactable_id: interactable_id,
        title: options[:title] || humanize_id(interactable_id),
        description: options[:description],
        group: options[:group],
        action_type: options[:action_type]
      },
      force: options[:force]
    )

    puts "Created #{relative_to_root(File.join(interactables_dir, "#{interactable_id}.yaml"))}"
  end

  def scaffold_node(argv)
    options = {
      sound_profile: "silent_tomb",
      theme: "unassigned",
      discovered: false
    }

    parser = OptionParser.new do |opts|
      opts.banner = "Usage: ./Scripts/scaffold_authoring.rb node <scenario_id> <node_id> <node_name> [options]"
      opts.on("--sound-profile NAME", "Initial sound profile") { |value| options[:sound_profile] = value }
      opts.on("--theme NAME", "Initial theme label") { |value| options[:theme] = value }
      opts.on("--discovered", "Start discovered") { options[:discovered] = true }
    end

    parser.parse!(argv)
    scenario_id = argv.shift
    node_id = argv.shift
    node_name = argv.join(" ").strip
    raise ScaffoldError, parser.to_s unless scenario_id && node_id && !node_name.empty?

    scenario_dir = require_scenario_dir(scenario_id)
    map_path = File.join(scenario_dir, "map.yaml")
    raise ScaffoldError, "Expected #{relative_to_root(map_path)} to exist first" unless File.file?(map_path)

    map_contents = File.read(map_path)
    raise ScaffoldError, "#{relative_to_root(map_path)} does not contain a top-level nodes: section" unless map_contents.match?(/^nodes:\s*$/)
    if map_contents.match?(/^  #{Regexp.escape(node_id)}:\s*$/)
      raise ScaffoldError, "Node #{node_id.inspect} already exists in #{relative_to_root(map_path)}"
    end

    snippet = render_template(
      "node_snippet.yaml.erb",
      {
        node_id: node_id,
        node_name: node_name,
        sound_profile: options[:sound_profile],
        theme: options[:theme],
        discovered: options[:discovered] ? "true" : "false"
      }
    )

    File.write(map_path, ensure_trailing_newline(map_contents) + snippet)
    puts "Appended node #{node_id.inspect} to #{relative_to_root(map_path)}"
  end

  def write_template(template_name, destination_path, locals, force:)
    if File.exist?(destination_path) && !force
      raise ScaffoldError, "#{relative_to_root(destination_path)} already exists. Re-run with --force to overwrite."
    end

    FileUtils.mkdir_p(File.dirname(destination_path))
    File.write(destination_path, render_template(template_name, locals))
  end

  def render_template(template_name, locals)
    template_path = File.join(TEMPLATE_ROOT, template_name)
    ERB.new(File.read(template_path), trim_mode: "-").result_with_hash(locals)
  end

  def require_scenario_dir(scenario_id)
    scenario_dir = File.join(AUTHORING_ROOT, scenario_id)
    raise ScaffoldError, "No authored scenario found at #{relative_to_root(scenario_dir)}" unless Dir.exist?(scenario_dir)

    scenario_dir
  end

  def ensure_trailing_newline(text)
    text.end_with?("\n") ? text : "#{text}\n"
  end

  def relative_to_root(path)
    path.delete_prefix("#{ROOT_DIR}/")
  end

  def humanize_id(value)
    value.split(/[_-]+/).map(&:capitalize).join(" ")
  end

  def usage
    <<~USAGE
      Usage:
        ./Scripts/scaffold_authoring.rb scenario <scenario_id> <title> [options]
        ./Scripts/scaffold_authoring.rb event <scenario_id> <event_id> [options]
        ./Scripts/scaffold_authoring.rb interactable <scenario_id> <interactable_id> [options]
        ./Scripts/scaffold_authoring.rb node <scenario_id> <node_id> <node_name> [options]
    USAGE
  end
end

begin
  AuthoringScaffolder.new.run(ARGV)
rescue ScaffoldError => error
  warn error.message
  exit 1
end
