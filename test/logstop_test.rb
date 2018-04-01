require_relative "test_helper"

class LogstopTest < Minitest::Test
  def test_email
    assert_filtered "test@test.com"
  end

  def test_phone
    assert_filtered "555-555-5555"
    assert_filtered "555 555 5555"
    assert_filtered "5555555555"
  end

  def test_credit_card
    assert_filtered "4242-4242-4242-4242"
    assert_filtered "4242 4242 4242 4242"
    assert_filtered "4242424242424242"
  end

  def test_ssn
    assert_filtered "123-45-6789"
    assert_filtered "123 45 6789"
    assert_filtered "123456789"
  end

  def test_ip
    refute_filtered "127.0.0.1"
    assert_filtered "127.0.0.1", ip: true
  end

  def test_url_password
    assert_filtered "https://user:pass@host", expected: "https://user:[FILTERED]@host"
  end

  def test_scrub
    assert_equal "[FILTERED]", Logstop.scrub("test@test.com")
  end

  def test_multiple
    assert_filtered "test@test.com test2@test.com 123456789", expected: "[FILTERED] [FILTERED] [FILTERED]"
  end

  private

  def log(msg, **options)
    str = StringIO.new
    logger = Logger.new(str)
    logger.formatter = Logstop::Formatter.new(logger.formatter, **options)
    logger.info "begin #{msg} end"
    str.string.split(" : ", 2)[-1]
  end

  def assert_filtered(msg, expected: "[FILTERED]", **options)
    assert_equal "begin #{expected} end\n", log(msg, **options)
  end

  def refute_filtered(msg, **options)
    assert_filtered msg, expected: msg, **options
  end
end