#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "optparse"
require "yaml"

ROOT_DIR = File.expand_path("..", __dir__)
AUTHORING_ROOT = File.join(ROOT_DIR, "Authoring", "Scenarios")
DEFAULT_OUTPUT_DIR = File.join(ROOT_DIR, "Authoring", "Previews")

class PreviewError < StandardError; end

class AuthoredMapPreviewer
  def run(argv)
    options = {
      output_dir: DEFAULT_OUTPUT_DIR,
      stdout: false
    }

    parser = OptionParser.new do |opts|
      opts.banner = "Usage: ./Scripts/preview_authored_map.rb [scenario_id ...] [options]"
      opts.on("--stdout", "Print preview markdown instead of writing files") { options[:stdout] = true }
      opts.on("--output-dir PATH", "Directory for generated previews") { |value| options[:output_dir] = File.expand_path(value, ROOT_DIR) }
    end

    parser.parse!(argv)
    scenario_ids = argv.empty? ? authored_scenarios : argv
    raise PreviewError, "No authored scenarios found under #{relative_to_root(AUTHORING_ROOT)}" if scenario_ids.empty?

    FileUtils.mkdir_p(options[:output_dir]) unless options[:stdout]

    scenario_ids.each do |scenario_id|
      preview = build_preview(scenario_id)
      if options[:stdout]
        puts preview
      else
        output_path = File.join(options[:output_dir], "#{scenario_id}_map_preview.md")
        File.write(output_path, preview)
        puts "Wrote #{relative_to_root(output_path)}"
      end
    end
  end

  private

  def build_preview(scenario_id)
    scenario_dir = File.join(AUTHORING_ROOT, scenario_id)
    map_path = File.join(scenario_dir, "map.yaml")
    raise PreviewError, "Missing #{relative_to_root(map_path)}" unless File.file?(map_path)

    map_document = deep_stringify(YAML.safe_load(File.read(map_path), aliases: true))
    nodes = map_document["nodes"]
    raise PreviewError, "#{relative_to_root(map_path)} is missing nodes" unless nodes.is_a?(Hash)

    starting_node = map_document["startingNode"] || map_document["startingNodeID"]
    raise PreviewError, "#{relative_to_root(map_path)} is missing startingNode" unless starting_node

    scenario_document = load_yaml_if_present(find_yaml_file(scenario_dir, "scenario"))
    scenario_title = scenario_document&.dig("title") || scenario_id
    scenario_description = scenario_document&.dig("description")
    native_archetype_ids = Array(scenario_document&.dig("nativeArchetypeIDs"))
    content_summary = build_content_summary(scenario_dir, nodes)
    edges = collect_edges(nodes)
    reachable = reachable_nodes(nodes, starting_node.to_s)
    missing_targets = edges.reject { |edge| nodes.key?(edge[:to]) }.map { |edge| edge[:to] }.uniq.sort
    unreachable = nodes.keys.reject { |node_id| reachable.include?(node_id) }.sort

    lines = []
    lines << "# #{scenario_title} Map Preview"
    lines << ""
    lines << "_Generated from `#{relative_to_root(map_path)}`._"
    lines << ""
    lines << "## Scenario"
    lines << ""
    lines << "- Scenario ID: `#{scenario_id}`"
    if scenario_document
      lines << "- Party size: #{scenario_document["partySize"] || "-"}"
      lines << "- Native archetypes: #{native_archetype_ids.empty? ? "none" : native_archetype_ids.map { |id| "`#{id}`" }.join(", ")}"
      lines << "- Stress overflow harm family: `#{scenario_document["stressOverflowHarmFamilyID"] || "mental_fraying (default)"}`"
    end
    lines << "- Description: #{scenario_description || "No description in scenario.yaml."}"
    lines << ""
    lines << "## Content Summary"
    lines << ""
    lines << "- Primary source files: #{format_source_files(content_summary[:primary_source_files])}"
    lines << "- Split event files: #{content_summary[:split_event_file_count]}"
    lines << "- Split interactable files: #{content_summary[:split_interactable_file_count]}"
    lines << "- Archetypes: #{content_summary[:archetype_count]}"
    lines << "- Shared interactables: #{format_interactable_summary(content_summary[:shared_interactables])}"
    lines << "- Inline map interactables: #{content_summary[:inline_map_interactable_count]}"
    lines << "- Clocks: #{content_summary[:clock_count]}"
    lines << "- Treasures: #{content_summary[:treasure_count]}"
    lines << "- Harm families: #{content_summary[:harm_family_count]}"
    lines << "- Events: #{content_summary[:event_count]}"
    lines << ""
    lines << "## Summary"
    lines << ""
    lines << "- Starting node: `#{starting_node}`"
    lines << "- Nodes: #{nodes.size}"
    lines << "- Connections: #{edges.size} (#{edges.count { |edge| edge[:is_unlocked] }} unlocked, #{edges.count { |edge| !edge[:is_unlocked] }} locked)"
    lines << "- Unreachable nodes: #{unreachable.empty? ? "none" : unreachable.map { |node_id| "`#{node_id}`" }.join(", ")}"
    lines << "- Missing connection targets: #{missing_targets.empty? ? "none" : missing_targets.map { |node_id| "`#{node_id}`" }.join(", ")}"
    lines << ""
    lines << "## Diagram"
    lines << ""
    lines.concat(mermaid_diagram(nodes, edges, starting_node.to_s, reachable))
    lines << ""
    lines << "## Nodes"
    lines << ""
    lines << "| Symbolic ID | Name | Theme | Discovered | Interactables | Connections |"
    lines << "| --- | --- | --- | --- | ---: | ---: |"

    nodes.keys.sort.each do |node_id|
      node = nodes.fetch(node_id)
      lines << "| `#{node_id}` | #{node.fetch("name", node_id)} | #{node["theme"] || "-"} | #{node.fetch("isDiscovered", false)} | #{Array(node["interactables"]).size} | #{Array(node["connections"]).size} |"
    end

    lines << ""
    lines << "## Connection Notes"
    lines << ""
    if edges.empty?
      lines << "- No authored connections."
    else
      edges.each do |edge|
        lock_state = edge[:is_unlocked] ? "unlocked" : "locked"
        lines << "- `#{edge[:from]}` -> `#{edge[:to]}` (#{lock_state}): #{edge[:description]}"
      end
    end

    "#{lines.join("\n")}\n"
  end

  def authored_scenarios
    return [] unless Dir.exist?(AUTHORING_ROOT)

    Dir.children(AUTHORING_ROOT).sort.select do |entry|
      Dir.exist?(File.join(AUTHORING_ROOT, entry))
    end
  end

  def build_content_summary(scenario_dir, nodes)
    primary_source_files = [
      "scenario.yaml",
      "archetypes.yaml",
      "map.yaml",
      "clocks.yaml",
      "treasures.yaml",
      "harm_families.yaml",
      "interactables.yaml"
    ].select { |filename| File.file?(File.join(scenario_dir, filename)) }

    archetypes = load_yaml_if_present(File.join(scenario_dir, "archetypes.yaml"))
    clocks = load_yaml_if_present(File.join(scenario_dir, "clocks.yaml"))
    treasures = load_yaml_if_present(File.join(scenario_dir, "treasures.yaml"))
    harm_families = load_yaml_if_present(File.join(scenario_dir, "harm_families.yaml"))
    inline_interactables = load_yaml_if_present(find_yaml_file(scenario_dir, "interactables"))

    shared_interactables = summarize_interactable_collection(inline_interactables)
    split_interactable_paths = Dir[File.join(scenario_dir, "interactables", "*.{yaml,yml}")].sort
    split_interactable_paths.each do |path|
      merge_interactable_summary!(shared_interactables, summarize_interactable_collection(load_yaml_if_present(path)))
    end

    inline_events_path = find_yaml_file(scenario_dir, "events")
    event_count = count_events(load_yaml_if_present(inline_events_path))
    split_event_paths = Dir[File.join(scenario_dir, "events", "*.{yaml,yml}")].sort
    split_event_paths.each do |path|
      event_count += count_events(load_yaml_if_present(path))
    end

    {
      primary_source_files: primary_source_files,
      split_event_file_count: split_event_paths.count,
      split_interactable_file_count: split_interactable_paths.count,
      archetype_count: count_array_entries(archetypes),
      shared_interactables: shared_interactables,
      inline_map_interactable_count: nodes.values.sum { |node| Array(node["interactables"]).size },
      clock_count: count_array_entries(clocks),
      treasure_count: count_array_entries(treasures),
      harm_family_count: count_harm_families(harm_families),
      event_count: event_count
    }
  end

  def collect_edges(nodes)
    nodes.keys.sort.flat_map do |node_id|
      node = nodes.fetch(node_id)
      Array(node["connections"]).map do |connection|
        hash = deep_stringify(connection || {})
        {
          from: node_id,
          to: (hash["to"] || hash["toNodeID"] || "").to_s,
          is_unlocked: hash.fetch("isUnlocked", true),
          description: hash["description"] || ""
        }
      end
    end
  end

  def reachable_nodes(nodes, starting_node)
    return [] unless nodes.key?(starting_node)

    visited = { starting_node => true }
    queue = [starting_node]
    head = 0

    while head < queue.length
      current = queue[head]
      head += 1

      Array(nodes.fetch(current).fetch("connections", [])).each do |connection|
        target = deep_stringify(connection || {})["to"] || deep_stringify(connection || {})["toNodeID"]
        next unless target && nodes.key?(target.to_s)
        next if visited.key?(target.to_s)

        visited[target.to_s] = true
        queue << target.to_s
      end
    end

    visited.keys
  end

  def mermaid_diagram(nodes, edges, starting_node, reachable)
    id_lookup = {}
    nodes.keys.sort.each_with_index do |node_id, index|
      id_lookup[node_id] = "n#{index}"
    end

    lines = ["```mermaid", "graph TD"]
    lines << "classDef start fill:#d3b15d,stroke:#5f4410,color:#1d1406;"
    lines << "classDef discovered fill:#f6ecd0,stroke:#7d6630,color:#2d210e;"
    lines << "classDef hidden fill:#e4dcc8,stroke:#8c7f63,color:#403624;"
    lines << "classDef unreachable fill:#ead7d4,stroke:#8a544b,color:#3e1f1b;"

    nodes.keys.sort.each do |node_id|
      node = nodes.fetch(node_id)
      mermaid_id = id_lookup.fetch(node_id)
      label = "#{node.fetch("name", node_id)}\\n#{node_id}"
      lines << "#{mermaid_id}[\"#{escape_mermaid(label)}\"]"

      css_class =
        if node_id == starting_node
          "start"
        elsif !reachable.include?(node_id)
          "unreachable"
        elsif node.fetch("isDiscovered", false)
          "discovered"
        else
          "hidden"
        end
      lines << "class #{mermaid_id} #{css_class};"
    end

    edges.each do |edge|
      next unless id_lookup.key?(edge[:from]) && id_lookup.key?(edge[:to])

      edge_label = edge[:description]
      if edge[:is_unlocked]
        lines << "#{id_lookup.fetch(edge[:from])} -- \"#{escape_mermaid(edge_label)}\" --> #{id_lookup.fetch(edge[:to])}"
      else
        lines << "#{id_lookup.fetch(edge[:from])} -. \"#{escape_mermaid("#{edge_label} (locked)")}\" .-> #{id_lookup.fetch(edge[:to])}"
      end
    end

    lines << "```"
    lines
  end

  def escape_mermaid(text)
    text.to_s.gsub("\\", "\\\\\\").gsub("\"", "\\\"")
  end

  def deep_stringify(value)
    case value
    when Array
      value.map { |item| deep_stringify(item) }
    when Hash
      value.each_with_object({}) do |(key, item), transformed|
        transformed[key.to_s] = deep_stringify(item)
      end
    else
      value
    end
  end

  def load_yaml_if_present(path)
    return nil unless path && File.file?(path)

    deep_stringify(YAML.safe_load(File.read(path), aliases: true))
  end

  def find_yaml_file(directory, basename)
    [".yaml", ".yml"]
      .map { |extension| File.join(directory, "#{basename}#{extension}") }
      .find { |candidate| File.file?(candidate) }
  end

  def count_array_entries(document)
    document.is_a?(Array) ? document.count : 0
  end

  def count_harm_families(document)
    return 0 unless document

    if document.is_a?(Hash) && document["families"].is_a?(Array)
      document["families"].count
    elsif document.is_a?(Array)
      document.count
    else
      0
    end
  end

  def count_events(document)
    case document
    when Array
      document.count
    when Hash
      1
    else
      0
    end
  end

  def summarize_interactable_collection(document)
    summary = {
      total: 0,
      groups: Hash.new(0)
    }

    case document
    when Array
      summary[:total] += document.count
    when Hash
      if interactable_groups_hash?(document)
        document.each do |group_name, entries|
          count = Array(entries).count
          summary[:groups][group_name.to_s] += count
          summary[:total] += count
        end
      else
        group_name = (document["authoringGroup"] || document["group"])&.to_s
        summary[:groups][group_name] += 1 if group_name
        summary[:total] += 1
      end
    end

    summary
  end

  def merge_interactable_summary!(base, addition)
    base[:total] += addition[:total]
    addition[:groups].each do |group_name, count|
      base[:groups][group_name] += count
    end
  end

  def interactable_groups_hash?(document)
    return false unless document.is_a?(Hash)
    return false if document.key?("id") || document.key?("title") || document.key?("availableActions")

    document.values.all? { |value| value.is_a?(Array) }
  end

  def format_source_files(files)
    return "none" if files.empty?

    files.map { |filename| "`#{filename}`" }.join(", ")
  end

  def format_interactable_summary(summary)
    return "0" if summary[:total].zero?

    group_breakdown = summary[:groups]
      .sort_by { |group_name, _| group_name }
      .map { |group_name, count| "`#{group_name}`: #{count}" }

    if group_breakdown.empty?
      summary[:total].to_s
    else
      "#{summary[:total]} (#{group_breakdown.join(", ")})"
    end
  end

  def relative_to_root(path)
    path.delete_prefix("#{ROOT_DIR}/")
  end
end

begin
  AuthoredMapPreviewer.new.run(ARGV)
rescue PreviewError => error
  warn error.message
  exit 1
end
