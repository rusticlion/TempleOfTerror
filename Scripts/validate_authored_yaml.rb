#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "set"
require "yaml"

class AuthoredValidationError < StandardError; end

class AuthoredValidationIssue
  attr_reader :file, :path, :message

  def initialize(file:, path:, message:)
    @file = file
    @path = path
    @message = message
  end

  def formatted_description
    location = path.nil? || path.empty? ? file : "#{file} :: #{path}"
    "[ERROR] #{location}: #{message}"
  end
end

class AuthoredValidationReport
  attr_reader :scenario_id, :issues

  def initialize(scenario_id)
    @scenario_id = scenario_id
    @issues = []
  end

  def add(file:, path: nil, message:)
    issues << AuthoredValidationIssue.new(file: file, path: path, message: message)
  end

  def errors
    issues
  end

  def formatted_description
    return "#{scenario_id}: no issues" if issues.empty?

    ([scenario_id] + issues.map(&:formatted_description)).join("\n")
  end
end

class AuthoredYAMLValidator
  BASE_DOCUMENT_SCHEMAS = {
    "scenario" => "scenario.schema.json",
    "archetypes" => "archetypes.schema.json",
    "clocks" => "clocks.schema.json",
    "treasures" => "treasures.schema.json",
    "harm_families" => "harm_families.schema.json",
    "map" => "map.schema.json",
    "interactables" => "interactables.schema.json",
    "events" => "events.schema.json"
  }.freeze
  SPLIT_DIRECTORY_SCHEMAS = {
    "events" => "event.schema.json",
    "interactables" => "interactable_entry.schema.json"
  }.freeze
  META_SCHEMA_KEYS = Set["$schema", "$id", "title", "description", "default"]

  PropertySchema = Struct.new(:schema, :schema_path, keyword_init: true)
  ObjectConstraints = Struct.new(
    :properties,
    :required,
    :property_names,
    :additional_properties,
    :unevaluated_properties,
    keyword_init: true
  )

  def initialize(root_dir)
    @root_dir = root_dir
    @authoring_root = File.join(root_dir, "Authoring", "Scenarios")
    @schemas_root = File.join(root_dir, "Authoring", "Schemas")
    @schema_cache = {}
  end

  def run(argv)
    scenario_ids = argv.empty? ? authored_scenarios : argv.map { |raw| normalize_scenario_id(raw) }
    raise AuthoredValidationError, "No authored scenarios found under #{relative_to_root(@authoring_root)}" if scenario_ids.empty?

    reports = scenario_ids.map { |scenario_id| validate_scenario(scenario_id) }
    error_count = reports.sum { |report| report.errors.count }

    reports.each do |report|
      puts report.formatted_description
      puts "---"
    end

    puts "Authored YAML validation complete: #{reports.count} scenario(s), #{error_count} error(s)."
    exit(error_count.zero? ? 0 : 1)
  end

  private

  def validate_scenario(scenario_id)
    source_dir = File.join(@authoring_root, scenario_id)
    report = AuthoredValidationReport.new(scenario_id)

    unless Dir.exist?(source_dir)
      report.add(
        file: scenario_id,
        message: "No authored scenario found at #{relative_to_root(source_dir)}."
      )
      return report
    end

    BASE_DOCUMENT_SCHEMAS.each do |basename, schema_name|
      validate_named_document(source_dir, basename, schema_name, report)
    end

    SPLIT_DIRECTORY_SCHEMAS.each do |directory_name, schema_name|
      validate_split_directory(source_dir, directory_name, schema_name, report)
    end

    report
  end

  def validate_named_document(source_dir, basename, schema_name, report)
    candidates = yaml_candidates(source_dir, basename)
    if candidates.length > 1
      report.add(
        file: basename,
        message: "Found both #{File.basename(candidates.first)} and #{File.basename(candidates.last)}. Keep only one extension."
      )
      return
    end

    path = candidates.first
    return unless path

    validate_document(path, File.join(@schemas_root, schema_name), report, source_dir)
  end

  def validate_split_directory(source_dir, directory_name, schema_name, report)
    directory = File.join(source_dir, directory_name)
    return unless Dir.exist?(directory)

    grouped_candidates = Dir[File.join(directory, "*.{yaml,yml}")].sort.group_by do |path|
      File.basename(path, File.extname(path))
    end

    grouped_candidates.each_value do |paths|
      if paths.length > 1
        report.add(
          file: relative_to_scenario(paths.first, source_dir),
          message: "Found both #{File.basename(paths.first)} and #{File.basename(paths.last)}. Keep only one extension per entry."
        )
        next
      end

      validate_document(paths.first, File.join(@schemas_root, schema_name), report, source_dir)
    end
  end

  def validate_document(document_path, schema_path, report, source_dir)
    relative_file = relative_to_scenario(document_path, source_dir)
    document = load_yaml(document_path, report, relative_file)
    return if document.nil?

    issues = []
    validate_value(document, load_schema_document(schema_path), schema_path, relative_file, [], issues)
    issues.each do |issue|
      report.add(file: issue.file, path: issue.path, message: issue.message)
    end
  rescue AuthoredValidationError => error
    report.add(file: relative_file, message: error.message)
  end

  def load_yaml(path, report, relative_file)
    document = YAML.safe_load(File.read(path), aliases: true)
    if document.nil?
      report.add(file: relative_file, message: "File is empty.")
      return nil
    end

    document
  rescue Psych::Exception => error
    report.add(file: relative_file, message: "Failed to parse YAML: #{error.message}")
    nil
  end

  def validate_value(value, schema, schema_path, file, path_segments, issues)
    schema, schema_path = unwrap_pure_ref(schema, schema_path)

    if schema.key?("oneOf")
      match_count = Array(schema["oneOf"]).count do |candidate|
        valid_against_schema?(value, candidate, schema_path)
      end
      if match_count != 1
        issues << issue(file, path_segments, "Value does not match exactly one allowed form.")
        return
      end
    end

    if schema.key?("anyOf")
      matches_any = Array(schema["anyOf"]).any? do |candidate|
        valid_against_schema?(value, candidate, schema_path)
      end
      unless matches_any
        issues << issue(file, path_segments, "Value does not match any allowed form.")
        return
      end
    end

    if object_schema?(schema)
      unless value.is_a?(Hash)
        issues << issue(file, path_segments, "Expected an object.")
        return
      end
      validate_object(value, schema, schema_path, file, path_segments, issues)
    elsif array_schema?(schema)
      unless value.is_a?(Array)
        issues << issue(file, path_segments, "Expected an array.")
        return
      end
      validate_array(value, schema, schema_path, file, path_segments, issues)
    else
      validate_scalar_type(value, schema, file, path_segments, issues)
    end

    validate_enum(value, schema, file, path_segments, issues)
    validate_const(value, schema, file, path_segments, issues)
    validate_pattern(value, schema, file, path_segments, issues)
    validate_minimum(value, schema, file, path_segments, issues)
  end

  def validate_object(value, schema, schema_path, file, path_segments, issues)
    constraints = collect_object_constraints(schema, schema_path)

    constraints.required.each do |required_key|
      next if value.key?(required_key)

      issues << issue(file, path_segments + [required_key], "Missing required field.")
    end

    if constraints.property_names
      value.each_key do |key|
        next if valid_against_schema?(key, constraints.property_names.schema, constraints.property_names.schema_path)

        issues << issue(file, path_segments + [key], "Property name is not allowed.")
      end
    end

    value.each do |key, child|
      property = constraints.properties[key]
      next unless property

      validate_value(child, property.schema, property.schema_path, file, path_segments + [key], issues)
    end

    unknown_keys = value.keys - constraints.properties.keys
    if constraints.additional_properties == false || constraints.unevaluated_properties == false
      unknown_keys.each do |key|
        issues << issue(file, path_segments + [key], "Unknown field.")
      end
    elsif constraints.additional_properties.is_a?(PropertySchema)
      unknown_keys.each do |key|
        validate_value(
          value.fetch(key),
          constraints.additional_properties.schema,
          constraints.additional_properties.schema_path,
          file,
          path_segments + [key],
          issues
        )
      end
    end
  end

  def validate_array(value, schema, schema_path, file, path_segments, issues)
    items_schema = schema["items"]
    return unless items_schema

    value.each_with_index do |item, index|
      validate_value(item, items_schema, schema_path, file, path_segments + ["[#{index}]"], issues)
    end
  end

  def validate_scalar_type(value, schema, file, path_segments, issues)
    expected_type = schema["type"]
    return unless expected_type

    valid =
      case expected_type
      when "string"
        value.is_a?(String)
      when "integer"
        value.is_a?(Integer)
      when "boolean"
        value == true || value == false
      when "number"
        value.is_a?(Numeric)
      when "null"
        value.nil?
      else
        true
      end

    return if valid

    issues << issue(file, path_segments, "Expected #{article_for(expected_type)} #{expected_type}.")
  end

  def validate_enum(value, schema, file, path_segments, issues)
    return unless schema.key?("enum")
    return if schema.fetch("enum").include?(value)

    allowed = schema.fetch("enum").map(&:inspect).join(", ")
    issues << issue(file, path_segments, "Expected one of #{allowed}.")
  end

  def validate_const(value, schema, file, path_segments, issues)
    return unless schema.key?("const")
    return if value == schema.fetch("const")

    issues << issue(file, path_segments, "Expected #{schema.fetch("const").inspect}.")
  end

  def validate_pattern(value, schema, file, path_segments, issues)
    return unless schema.key?("pattern")
    return unless value.is_a?(String)

    regexp = Regexp.new(schema.fetch("pattern"))
    return if value.match?(regexp)

    issues << issue(file, path_segments, "Value does not match required pattern #{schema.fetch("pattern").inspect}.")
  end

  def validate_minimum(value, schema, file, path_segments, issues)
    return unless schema.key?("minimum")
    return unless value.is_a?(Numeric)
    return if value >= schema.fetch("minimum")

    issues << issue(file, path_segments, "Expected a value of at least #{schema.fetch("minimum")}.")
  end

  def object_schema?(schema)
    schema["type"] == "object" || schema.key?("properties") || schema.key?("required") ||
      schema.key?("additionalProperties") || schema.key?("propertyNames") ||
      schema.key?("unevaluatedProperties") || schema.key?("allOf")
  end

  def array_schema?(schema)
    schema["type"] == "array" || schema.key?("items")
  end

  def collect_object_constraints(schema, schema_path, visited = Set.new)
    schema, schema_path = unwrap_pure_ref(schema, schema_path)
    visit_key = "#{schema_path}:#{schema.object_id}"
    raise AuthoredValidationError, "Encountered a recursive schema reference in #{relative_to_root(schema_path)}." if visited.include?(visit_key)

    visited.add(visit_key)
    constraints = ObjectConstraints.new(
      properties: {},
      required: Set.new,
      property_names: nil,
      additional_properties: nil,
      unevaluated_properties: nil
    )

    Array(schema["allOf"]).each do |subschema|
      merge_object_constraints!(
        constraints,
        collect_object_constraints(subschema, schema_path, visited.dup)
      )
    end

    if schema.key?("$ref") && !pure_ref_schema?(schema)
      referenced_schema, referenced_path = resolve_ref(schema.fetch("$ref"), schema_path)
      merge_object_constraints!(
        constraints,
        collect_object_constraints(referenced_schema, referenced_path, visited.dup)
      )
    end

    if schema["properties"].is_a?(Hash)
      schema.fetch("properties").each do |key, subschema|
        constraints.properties[key] = PropertySchema.new(schema: subschema, schema_path: schema_path)
      end
    end

    Array(schema["required"]).each { |key| constraints.required << key }

    if schema["propertyNames"]
      constraints.property_names = PropertySchema.new(schema: schema.fetch("propertyNames"), schema_path: schema_path)
    end

    if schema.key?("additionalProperties")
      constraints.additional_properties =
        case schema["additionalProperties"]
        when false
          false
        when Hash
          PropertySchema.new(schema: schema.fetch("additionalProperties"), schema_path: schema_path)
        else
          nil
        end
    end

    constraints.unevaluated_properties = false if schema["unevaluatedProperties"] == false
    constraints
  end

  def merge_object_constraints!(target, source)
    target.properties.merge!(source.properties)
    target.required.merge(source.required)
    target.property_names ||= source.property_names
    if source.additional_properties == false || target.additional_properties == false
      target.additional_properties = false
    elsif source.additional_properties
      target.additional_properties = source.additional_properties
    end
    target.unevaluated_properties = false if source.unevaluated_properties == false
  end

  def valid_against_schema?(value, schema, schema_path)
    issues = []
    validate_value(value, schema, schema_path, "(validation)", [], issues)
    issues.empty?
  end

  def unwrap_pure_ref(schema, schema_path)
    current_schema = schema
    current_path = schema_path

    while pure_ref_schema?(current_schema)
      current_schema, current_path = resolve_ref(current_schema.fetch("$ref"), current_path)
    end

    [current_schema, current_path]
  end

  def pure_ref_schema?(schema)
    return false unless schema.is_a?(Hash) && schema.key?("$ref")

    (schema.keys - META_SCHEMA_KEYS.to_a - ["$ref"]).empty?
  end

  def resolve_ref(ref, schema_path)
    file_part, fragment = ref.split("#", 2)
    target_path =
      if file_part.nil? || file_part.empty?
        schema_path
      else
        File.expand_path(file_part, File.dirname(schema_path))
      end

    document = load_schema_document(target_path)
    target_schema =
      if fragment.nil? || fragment.empty?
        document
      else
        dereference_json_pointer(document, fragment)
      end

    [target_schema, target_path]
  end

  def dereference_json_pointer(document, fragment)
    pointer = fragment.start_with?("/") ? fragment : "/#{fragment}"
    pointer.split("/").drop(1).reduce(document) do |node, raw_token|
      token = raw_token.gsub("~1", "/").gsub("~0", "~")
      case node
      when Hash
        raise AuthoredValidationError, "Unknown schema pointer #{fragment.inspect}." unless node.key?(token)

        node.fetch(token)
      when Array
        index = Integer(token)
        node.fetch(index)
      else
        raise AuthoredValidationError, "Could not resolve schema pointer #{fragment.inspect}."
      end
    end
  rescue ArgumentError, IndexError => error
    raise AuthoredValidationError, "Invalid schema pointer #{fragment.inspect}: #{error.message}"
  end

  def load_schema_document(path)
    @schema_cache[path] ||= JSON.parse(File.read(path))
  rescue JSON::ParserError => error
    raise AuthoredValidationError, "Failed to parse schema #{relative_to_root(path)}: #{error.message}"
  rescue Errno::ENOENT
    raise AuthoredValidationError, "Missing schema file #{relative_to_root(path)}."
  end

  def authored_scenarios
    return [] unless Dir.exist?(@authoring_root)

    Dir.children(@authoring_root).sort.select do |entry|
      Dir.exist?(File.join(@authoring_root, entry))
    end
  end

  def normalize_scenario_id(raw)
    trimmed = raw.to_s.sub(%r{/\z}, "")
    return trimmed if Dir.exist?(File.join(@authoring_root, trimmed))

    File.basename(trimmed)
  end

  def yaml_candidates(directory, basename)
    [".yaml", ".yml"].map { |extension| File.join(directory, "#{basename}#{extension}") }.select { |path| File.file?(path) }
  end

  def relative_to_root(path)
    path.delete_prefix("#{@root_dir}/")
  end

  def relative_to_scenario(path, scenario_dir)
    path.delete_prefix("#{scenario_dir}/")
  end

  def issue(file, path_segments, message)
    AuthoredValidationIssue.new(
      file: file,
      path: format_path(path_segments),
      message: message
    )
  end

  def format_path(path_segments)
    return nil if path_segments.empty?

    path_segments.each_with_object(+"") do |segment, buffer|
      if segment.start_with?("[")
        buffer << segment
      else
        buffer << "." unless buffer.empty?
        buffer << segment
      end
    end
  end

  def article_for(type_name)
    %w[integer object array].include?(type_name) ? "an" : "a"
  end
end

begin
  root_dir = File.expand_path("..", __dir__)
  AuthoredYAMLValidator.new(root_dir).run(ARGV)
rescue AuthoredValidationError => error
  warn error.message
  exit 1
end
