#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest/sha1"
require "fileutils"
require "json"
require "yaml"

class CompilationError < StandardError; end

class ScenarioCompiler
  DIRECT_DOCUMENTS = {
    "scenario.yaml" => "scenario.json",
    "archetypes.yaml" => "archetypes.json",
    "clocks.yaml" => "clocks.json",
    "treasures.yaml" => "treasures.json",
    "harm_families.yaml" => "harm_families.json"
  }.freeze

  EVENT_GLOB = "*.{yaml,yml}".freeze
  INTERACTABLE_GLOB = "*.{yaml,yml}".freeze
  UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i.freeze
  NODE_REF_KEYS = {
    "fromNode" => "fromNodeID",
    "toNode" => "toNodeID",
    "inNode" => "inNodeID"
  }.freeze

  def initialize(root_dir)
    @root_dir = root_dir
  end

  def compile_all(requested_ids = [])
    scenario_ids = requested_ids.empty? ? authored_scenarios : requested_ids
    raise CompilationError, "No authored scenarios found under #{authoring_root}" if scenario_ids.empty?

    scenario_ids.each { |scenario_id| compile_scenario(scenario_id) }
  end

  private

  def compile_scenario(scenario_id)
    source_dir = File.join(authoring_root, scenario_id)
    raise CompilationError, "No authored scenario found at #{source_dir}" unless Dir.exist?(source_dir)

    output_dir = File.join(content_root, scenario_id)
    FileUtils.mkdir_p(output_dir)
    previous_manifest = load_existing_json_object(File.join(output_dir, "scenario.json"))
    scenario_document = nil

    DIRECT_DOCUMENTS.each do |source_name, output_name|
      source_path = File.join(source_dir, source_name)
      output_path = File.join(output_dir, output_name)

      unless File.file?(source_path)
        remove_generated_file(output_path)
        next
      end

      document = deep_stringify(load_yaml(source_path))
      scenario_document = document if source_name == "scenario.yaml"
      write_json(output_path, document)
    end

    compile_interactables(source_dir, output_dir)
    node_lookup = compile_map(source_dir, output_dir, scenario_id, scenario_document, previous_manifest)
    compile_events(source_dir, output_dir, node_lookup)

    puts "Compiled #{scenario_id}"
  end

  def compile_map(source_dir, output_dir, scenario_id, scenario_document, previous_manifest)
    source_path = find_yaml_file(source_dir, "map")
    output_name = map_output_name(scenario_document, scenario_id)
    output_path = File.join(output_dir, output_name)
    stale_map_paths(output_dir, scenario_id, previous_manifest, output_name).each do |stale_path|
      remove_generated_file(stale_path)
    end

    unless source_path
      remove_generated_file(output_path)
      return {}
    end

    authored_map = deep_stringify(load_yaml(source_path))
    nodes = authored_map["nodes"]
    raise CompilationError, "#{source_path} is missing top-level nodes" unless nodes.is_a?(Hash)

    starting_node_ref = authored_map["startingNode"] || authored_map["startingNodeID"]
    raise CompilationError, "#{source_path} is missing startingNode" if starting_node_ref.nil?

    node_lookup = build_node_lookup(nodes, scenario_id, source_path)
    compiled_nodes = {}

    nodes.each do |symbolic_id, raw_node|
      node_path = "#{source_path}: nodes.#{symbolic_id}"
      node_hash = deep_stringify(raw_node || {})
      compiled_nodes[node_lookup.fetch(symbolic_id.to_s)] = {
        "id" => node_lookup.fetch(symbolic_id.to_s),
        "name" => require_key(node_hash, "name", node_path),
        "soundProfile" => require_key(node_hash, "soundProfile", node_path),
        "interactables" => transform_node_refs(node_hash.fetch("interactables", []), node_lookup, node_path),
        "connections" => compile_connections(node_hash.fetch("connections", []), node_lookup, node_path),
        "theme" => node_hash["theme"],
        "isDiscovered" => node_hash.fetch("isDiscovered", false),
        "onEnter" => node_hash.key?("onEnter") ? transform_node_refs(node_hash["onEnter"], node_lookup, "#{node_path}.onEnter") : nil,
        "onFirstEnter" => node_hash.key?("onFirstEnter") ? transform_node_refs(node_hash["onFirstEnter"], node_lookup, "#{node_path}.onFirstEnter") : nil
      }.compact
    end

    compiled_map = {
      "startingNodeID" => resolve_node_ref(starting_node_ref, node_lookup, "#{source_path}: startingNode"),
      "nodes" => compiled_nodes
    }

    write_json(output_path, compiled_map)
    node_lookup
  end

  def compile_connections(raw_connections, node_lookup, node_path)
    Array(raw_connections).map.with_index do |raw_connection, index|
      connection = deep_stringify(raw_connection || {})
      connection_path = "#{node_path}.connections[#{index}]"
      destination = connection["to"] || connection["toNodeID"]
      raise CompilationError, "#{connection_path} is missing to/toNodeID" if destination.nil?

      compiled_connection = {
        "toNodeID" => resolve_node_ref(destination, node_lookup, "#{connection_path}.to"),
        "isUnlocked" => connection.fetch("isUnlocked", true),
        "description" => require_key(connection, "description", connection_path)
      }

      if connection.key?("conditions")
        compiled_connection["conditions"] = transform_node_refs(
          connection["conditions"],
          node_lookup,
          "#{connection_path}.conditions"
        )
      end

      if connection.key?("onTraverse")
        compiled_connection["onTraverse"] = transform_node_refs(
          connection["onTraverse"],
          node_lookup,
          "#{connection_path}.onTraverse"
        )
      end

      compiled_connection
    end
  end

  def compile_events(source_dir, output_dir, node_lookup)
    event_sources = []
    output_path = File.join(output_dir, "events.json")

    inline_path = find_yaml_file(source_dir, "events")
    if inline_path
      event_sources.concat(normalize_event_collection(load_yaml(inline_path), inline_path))
    end

    Dir[File.join(source_dir, "events", EVENT_GLOB)].sort.each do |event_path|
      event_sources.concat(normalize_event_collection(load_yaml(event_path), event_path))
    end

    if event_sources.empty?
      remove_generated_file(output_path)
      return
    end

    write_json(output_path, transform_node_refs(event_sources, node_lookup, "#{source_dir}/events"))
  end

  def compile_interactables(source_dir, output_dir)
    output_path = File.join(output_dir, "interactables.json")
    inline_path = find_yaml_file(source_dir, "interactables")
    file_paths = Dir[File.join(source_dir, "interactables", INTERACTABLE_GLOB)].sort

    if inline_path.nil? && file_paths.empty?
      remove_generated_file(output_path)
      return
    end

    accumulator = init_interactable_accumulator(inline_path && deep_stringify(load_yaml(inline_path)), inline_path)

    file_paths.each do |interactable_path|
      merge_interactable_document(
        accumulator,
        deep_stringify(load_yaml(interactable_path)),
        interactable_path,
        from_split_file: true
      )
    end

    write_json(output_path, finalize_interactables(accumulator))
  end

  def normalize_event_collection(document, source_path)
    case document
    when Array
      document
    when Hash
      [document]
    else
      raise CompilationError, "#{source_path} must contain an event object or array"
    end
  end

  def build_node_lookup(nodes, scenario_id, source_path)
    lookup = {}
    reverse_lookup = {}

    nodes.each do |symbolic_id, raw_node|
      node = deep_stringify(raw_node || {})
      uuid = canonical_uuid_string(node["uuid"] || stable_uuid(scenario_id, symbolic_id.to_s), "#{source_path}: nodes.#{symbolic_id}.uuid")
      if reverse_lookup.key?(uuid)
        raise CompilationError, "#{source_path} assigns UUID #{uuid} to both #{reverse_lookup.fetch(uuid)} and #{symbolic_id}"
      end

      lookup[symbolic_id.to_s] = uuid
      reverse_lookup[uuid] = symbolic_id.to_s
    end

    lookup
  end

  def transform_node_refs(value, node_lookup, context)
    case value
    when Array
      value.map.with_index { |item, index| transform_node_refs(item, node_lookup, "#{context}[#{index}]") }
    when Hash
      value.each_with_object({}) do |(raw_key, raw_item), transformed|
        key = raw_key.to_s

        case key
        when "uuid"
          next
        when "fromNode", "toNode", "inNode"
          transformed[NODE_REF_KEYS.fetch(key)] = resolve_node_ref(raw_item, node_lookup, "#{context}.#{key}")
        when "fromNodeID", "toNodeID", "inNodeID"
          transformed[key] = resolve_node_ref(raw_item, node_lookup, "#{context}.#{key}")
        else
          transformed[key] = transform_node_refs(raw_item, node_lookup, "#{context}.#{key}")
        end
      end
    else
      value
    end
  end

  def resolve_node_ref(raw_value, node_lookup, context)
    value = raw_value.to_s
    return canonical_uuid_string(value, context) if value.match?(UUID_PATTERN)
    return node_lookup.fetch(value) if node_lookup.key?(value)

    raise CompilationError, "Unknown node reference #{value.inspect} at #{context}"
  end

  def map_output_name(scenario_document, scenario_id)
    scenario_document&.fetch("mapFile", nil) || "map_#{scenario_id}.json"
  end

  def stale_map_paths(output_dir, scenario_id, previous_manifest, current_output_name)
    previous_output_name = previous_manifest&.fetch("mapFile", nil) || "map_#{scenario_id}.json"
    candidate_names = [previous_output_name, "map_#{scenario_id}.json"].uniq
    candidate_names
      .reject { |name| name == current_output_name }
      .map { |name| File.join(output_dir, name) }
  end

  def authored_scenarios
    return [] unless Dir.exist?(authoring_root)

    Dir.children(authoring_root)
      .sort
      .select { |entry| Dir.exist?(File.join(authoring_root, entry)) }
  end

  def load_yaml(path)
    document = YAML.safe_load(File.read(path), aliases: true)
    raise CompilationError, "#{path} is empty" if document.nil?

    document
  rescue Psych::Exception => error
    raise CompilationError, "Failed to parse #{path}: #{error.message}"
  end

  def write_json(path, object)
    File.write(path, "#{JSON.pretty_generate(object)}\n")
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

  def require_key(hash, key, context)
    return hash.fetch(key) if hash.key?(key)

    raise CompilationError, "#{context} is missing #{key}"
  end

  def stable_uuid(scenario_id, symbolic_id)
    hex = Digest::SHA1.hexdigest("#{scenario_id}:#{symbolic_id}")[0, 32].chars
    hex[12] = "5"
    hex[16] = ((hex[16].to_i(16) & 0x3) | 0x8).to_s(16)

    [
      hex[0, 8].join,
      hex[8, 4].join,
      hex[12, 4].join,
      hex[16, 4].join,
      hex[20, 12].join
    ].join("-")
  end

  def canonical_uuid_string(raw_value, context)
    value = raw_value.to_s
    unless value.match?(UUID_PATTERN)
      raise CompilationError, "#{context} is not a valid UUID: #{value}"
    end

    value.upcase
  end

  def find_yaml_file(directory, basename)
    [".yaml", ".yml"]
      .map { |extension| File.join(directory, "#{basename}#{extension}") }
      .find { |candidate| File.file?(candidate) }
  end

  def init_interactable_accumulator(document, source_path)
    accumulator = {
      mode: nil,
      array: [],
      groups: {}
    }

    return accumulator if document.nil?

    merge_interactable_document(accumulator, document, source_path, from_split_file: false)
    accumulator
  end

  def merge_interactable_document(accumulator, document, source_path, from_split_file:)
    case document
    when Array
      document.each_with_index do |entry, index|
        merge_interactable_document(
          accumulator,
          deep_stringify(entry || {}),
          "#{source_path}[#{index}]",
          from_split_file: from_split_file
        )
      end
    when Hash
      if interactable_groups_hash?(document)
        ensure_interactable_mode(accumulator, :groups, source_path)
        document.each do |group_name, entries|
          Array(entries).each_with_index do |entry, index|
            merge_grouped_interactable_entry(
              accumulator,
              group_name.to_s,
              deep_stringify(entry || {}),
              "#{source_path}.#{group_name}[#{index}]",
              allow_authoring_group: from_split_file
            )
          end
        end
      else
        merge_single_interactable_entry(accumulator, document, source_path, from_split_file: from_split_file)
      end
    else
      raise CompilationError, "#{source_path} must contain an interactable object, array, or grouped collection"
    end
  end

  def merge_single_interactable_entry(accumulator, document, source_path, from_split_file:)
    entry = deep_stringify(document)
    group_name = (entry.delete("authoringGroup") || entry.delete("group"))&.to_s

    if group_name
      ensure_interactable_mode(accumulator, :groups, source_path)
      merge_grouped_interactable_entry(
        accumulator,
        group_name,
        entry,
        source_path,
        allow_authoring_group: false
      )
      return
    end

    if accumulator[:mode] == :groups && from_split_file
      raise CompilationError, "#{source_path} must set authoringGroup when the scenario uses grouped interactables"
    end

    ensure_interactable_mode(accumulator, :array, source_path)
    accumulator[:array] << entry
  end

  def merge_grouped_interactable_entry(accumulator, group_name, entry, source_path, allow_authoring_group:)
    sanitized_entry = deep_stringify(entry)
    if sanitized_entry.key?("authoringGroup") || sanitized_entry.key?("group")
      unless allow_authoring_group
        raise CompilationError, "#{source_path} may not nest authoringGroup inside a grouped interactable entry"
      end
      sanitized_entry.delete("authoringGroup")
      sanitized_entry.delete("group")
    end

    accumulator[:groups][group_name] ||= []
    accumulator[:groups][group_name] << sanitized_entry
  end

  def interactable_groups_hash?(document)
    return false if document.key?("id") || document.key?("title") || document.key?("availableActions")

    document.values.all? { |value| value.is_a?(Array) }
  end

  def ensure_interactable_mode(accumulator, desired_mode, source_path)
    return accumulator[:mode] = desired_mode if accumulator[:mode].nil?
    return if accumulator[:mode] == desired_mode

    raise CompilationError, "#{source_path} mixes flat interactable arrays with grouped interactable collections"
  end

  def finalize_interactables(accumulator)
    case accumulator[:mode]
    when :array
      accumulator[:array]
    when :groups
      accumulator[:groups]
    else
      []
    end
  end

  def load_existing_json_object(path)
    return nil unless File.file?(path)

    document = JSON.parse(File.read(path))
    document.is_a?(Hash) ? document : nil
  rescue JSON::ParserError
    nil
  end

  def remove_generated_file(path)
    FileUtils.rm_f(path)
  end

  def authoring_root
    File.join(@root_dir, "Authoring", "Scenarios")
  end

  def content_root
    File.join(@root_dir, "Content", "Scenarios")
  end
end

begin
  root_dir = File.expand_path("..", __dir__)
  compiler = ScenarioCompiler.new(root_dir)
  compiler.compile_all(ARGV)
rescue CompilationError => error
  warn error.message
  exit 1
end
