require 'httparty'
class Compete
  include HTTParty
  format :xml
  # Valid size arguments for the for_domain call
  VALID_SIZES = ['small', 'large']
  API_URL = 'http://api.compete.com/fast-cgi/MI'
  API_VERSION = 3
  
  # readers for trust data
  attr_reader(:trust_level_value, :trust_level_link, :trust_level_icon)
  # readers for metric data
  attr_reader(:metrics_link, :metrics_icon, :metrics_count, :metrics_ranking, :metrics_date_range)
  # other readers
  attr_reader(:domain, :xml)
  
  # 
  # Creates a new Compete Object from the XML response of the compete API (as parsed by httparty).
  # Details see http://developer.compete.com/
  #  
  def initialize(xml)
    @xml = xml
    @domain =  @xml['ci']['dmn']['nm']

    # metrics
    @metrics_ranking = to_integer(@xml['ci']['dmn']['metrics']['val']['uv']['ranking'])
    if data_available?
      @metrics_date_range = build_metrics_date_range()
    end
    
    # metrics
    @metrics_count = to_integer(@xml['ci']['dmn']['metrics']['val']['uv']['count'])
    @metrics_link = @xml['ci']['dmn']['metrics']['link']
    @metrics_icon = @xml['ci']['dmn']['metrics']['icon']

    # trust
    @trust_level_value = @xml['ci']['dmn']['trust']['val']
    @trust_level_link = @xml['ci']['dmn']['trust']['link']
    @trust_level_icon = @xml['ci']['dmn']['trust']['icon']

  end
  
  # Lookup the compete info for a domain.
  # the size argument is for the icon urls. VALID_SIZES specifies what you can give here.
  # Make sure COMPETE_API_KEY is set before you call this method.
  def self.for_domain(domain, size = 'small')
    raise 'COMPETE_API_KEY is not defined' unless defined?(COMPETE_API_KEY)
    raise "Unknown size '#{size}'" unless VALID_SIZES.include?(size)
    info = get(API_URL, :query => {:d => domain, :ver => API_VERSION, :apikey => COMPETE_API_KEY, :size => size})
    Compete.new(info)
  end
  
  # Is data available for this domain?
  # If this method returns true
  def data_available?
    !!self.metrics_ranking
  end
  
  private
  
  # Build a date range according to the year/month specified in the XML
  # Assuming month is 0 indexed (rubys month is 1 indexed) but there is nothing in the deco about it...
  def build_metrics_date_range()
    month = to_integer(@xml['ci']['dmn']['metrics']['val']['mth'])
    year = to_integer(@xml['ci']['dmn']['metrics']['val']['yr'])
    from = Date.new(year, month + 1)
    to = (from >> 1) - 1
    (from..to)
  end
  
  # Metrics count contains ',' as separator... 
  def to_integer(value)
    strip(value).gsub(',', '').to_i if value
  end
  
  # Strip all whitespace
  def strip(value)
    value.gsub(/\s/, '') if value
  end
end