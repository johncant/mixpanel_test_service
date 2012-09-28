module MixpanelTest

  class Analysis

    def initialize(options = {})

      @events_count = {}
      @events_properties_counts = {}
      @events_properties_values_counts = {}
      @properties_counts = {}
      @properties_values_counts = {}
      @super_properties_counts = {}
      @super_properties_values_counts = {}

    end

    def initialize_for_event(ev)

      name = ev["event"]

      initialize_for_event_property_list(name, ev["properties"].keys)

      ev["properties"].each do |k, v|

          # Initialize property counters
          @events_properties_values_counts[name][k][v] ||= 0
          @properties_values_counts[k][v] ||= 0

      end

    end

    def initialize_for_event_property_list(name, props)

      # Initialize counters
      @events_count[name] ||= 0
      @events_properties_counts[name] ||= {}
      @events_properties_values_counts[name] ||= {}

      props.each do |k|

        # Initialize property counters
        @events_properties_counts[name][k] ||= 0
        @events_properties_values_counts[name][k] ||= {}
        @properties_counts[k] ||= 0
        @properties_values_counts[k] ||= {}

      end

    end

    def add_documentation_object(obj)
      # Each event and property counts for an undefined number > 0.
      # Discard notes
      # Only useful for merging two documentation objects

      obj["events"].each do |name, props|

        initialize_for_event_property_list(name, props)
        @events_count[name] += 1

        props.each do |p_name|
          @events_properties_counts[name][p_name] += 1
          @properies_count[p_name] += 1
        end

      end

      obj["properties"].each do |p|
        @properties_count[p["name"]] ||= 0
        @properties_count[p["name"]] += 1

        p["values"].each do |v|
          @properties_values_count[p["name"]][v] ||= 0
          @properties_values_count[p["name"]][v] += 1
        end
      end
    end

    def add_events(arr)
      arr.each do |ev| add_event(ev) end
    end

    def add_event(ev)

      initialize_for_event(ev)
      name = ev["event"]

      ev["properties"].each do |k, v|

        # Increment property counters
        @properties_counts[k] += 1
        @events_properties_counts[name][k] += 1
        @events_properties_values_counts[name][k][v] += 1
        @properties_values_counts[k][v] += 1

      end

    end

    def format_verbose

      puts "Mixpanel events caught:"
      pp @events_count

      puts "Mixpanel properties caught for each event:"
      pp @events_properties_counts

      puts "All Mixpanel properties caught:"
      pp @properties_counts

      puts "Mixpanel values frequency by property:"
      pp @properties_values_counts

      puts "Mixpanel values frequency by property and event:"
      pp @events_properties_values_counts

    end

    def format_documentation

      pp documentation_object

    end

    def documentation_object
      default_notes = "Undocumented"
      {
        "events" => @events_count.keys.map do |k|
          {
            k => {
              "notes" => default_notes,
              "properties" => @events_properties_counts[k].keys
            }
          }
        end,
        "properties" => @properties_counts.keys.map do |k|
          {
            "name" => k,
            "notes" => default_notes,
            "values" => @properties_values_counts[k].keys
          }
        end
      }

    end

  end

end


