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

    def add_events(arr)
      arr.each do |ev| add_event(ev) end
    end

    def add_event(ev)

      name = ev["event"]

      # Initialize counters
      @events_count[name] ||= 0
      @events_properties_counts[name] ||= {}
      @events_properties_values[name] ||= {}

      # Update
      @events_count[name] += 1

      d["properties"].each do |k, v|

        unless @super_properties_counts[k]

          # Initialize property counters
          @events_properties_counts[name][k] ||= 0
          @events_properties_values_counts[name][k] ||= {}
          @events_properties_values_counts[name][k][v] ||= 0
          @properties_counts_counts[k] ||= 0
          @properties_values_counts[k] ||= {}
          @properties_values_counts[k][v] ||= 0

          # Increment property counters
          @properties_counts[k] += 1
          @events_properties_counts[name][k] += 1
          @events_properties_values_counts[name][k][v] += 1
          @properties_values_counts[k][v] += 1

        end

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
              "notes" => "",
              "properties" => @events_properties_counts.keys
            }
          }
        end,
        "properties" => @properties_counts.keys.map do |k|
          {
            "notes" => "",
            "values" => @properties_values_counts[k].keys
          }
        end
      }

    end

  end

end
