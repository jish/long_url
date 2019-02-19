require 'net/http'
require 'openssl'

class LongUrl

  def self.call(url)
    new.call(url)
  end

  MAX_REDIRECTS = 5

  def initialize
    @redirects = 0
  end

  def call(url)
    lengthen(url)
  end

  def lengthen(url)
    result = send_request(url)

    while result && result != url && @redirects < MAX_REDIRECTS
      url = result
      result = send_request(url)
    end

    result
  end

  def send_request(url)
    uri = parse_uri(url)
    request = Net::HTTP::Head.new(uri.path)
    http = get_connection(uri)

    begin
      response = http.start { |http| http.request(request) }
    rescue Timeout::Error
      $stderr.puts "Timeout connecting to `#{uri.scheme}://#{uri.host}`"
      exit(1)
    rescue SocketError
      $stderr.puts "It looks like you are not connected to the internet."
      exit(1)
    end

    case response
    when Net::HTTPMovedPermanently, Net::HTTPFound
      @redirects += 1
      response["Location"]
    when Net::HTTPClientError, Net::HTTPServerError
      nil
    else
      url
    end
  end

  def parse_uri(url)
    uri = URI.parse(url)

    if uri.path == ""
      uri.path = "/"
    end

    uri
  end

  def get_connection(uri)
    http = Net::HTTP.new(uri.hostname, uri.port)

    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.cert_store = get_cert_store
    end

    http.open_timeout = 1
    http.read_timeout = 1

    http
  end

  def get_cert_store
    store = OpenSSL::X509::Store.new
    store.set_default_paths
    store
  end

end
