require 'test_helper'

class CompeteTest < Test::Unit::TestCase
  should 'deal with unknown domain' do
    file = File.dirname(__FILE__) + '/data/unknown.yml'
    info = YAML::load_file(file)
    compete = Compete.new(info)
    assert(!compete.data_available?)
    assert_equal('yellow', compete.trust_level_value)
    assert(compete.trust_level_link)
    assert(compete.trust_level_icon)
    assert(!compete.metrics_link)
    assert(compete.metrics_icon)
    assert(!compete.metrics_ranking)
    assert(!compete.metrics_date_range)
    assert(!compete.metrics_count)
    assert_equal('unknowndomain.something.notknow', compete.domain)
  end
  
  should 'find infos about known domain' do
      file = File.dirname(__FILE__) + '/data/google.com.yml'
      info = YAML::load_file(file)
      compete = Compete.new(info)
      assert(compete.data_available?)
      assert_equal('green', compete.trust_level_value)
      assert(compete.trust_level_link)
      assert(compete.trust_level_icon)
      assert(compete.metrics_link)
      assert(compete.metrics_icon)
      assert_equal(1, compete.metrics_ranking)
      assert_equal(137630925, compete.metrics_count)
      assert_equal((Date.new(2009, 4, 1)..Date.new(2009, 4, 30)), compete.metrics_date_range)
      assert_equal('google.com', compete.domain)
  end
end
