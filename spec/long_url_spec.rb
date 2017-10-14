require 'webmock/rspec'
require 'long_url'

describe LongUrl do

  # live test
  # it 'Lengthens a URL' do
  #   url = "http://bit.ly/O44xP7"
  #   url = LongUrl.call(url)
  #   url.should eq("https://github.com/jakobwesthoff/colorizer")
  # end

  it 'Lengthens a URL' do
    url = "http://bit.ly/O44xP7"
    stub_redirect(url, "https://github.com/jakobwesthoff/colorizer")
    stub_request(:head, "https://github.com/jakobwesthoff/colorizer").to_return(:status => 200)

    url = LongUrl.call(url)
    expect(url).to eq("https://github.com/jakobwesthoff/colorizer")
  end

  it "Lengthens on temporary redirects" do
    url = "http://bit.ly/O44xP7"
    stub_redirect(url, "https://github.com/jakobwesthoff/colorizer", 302)
    stub_request(:head, "https://github.com/jakobwesthoff/colorizer").to_return(:status => 200)

    url = LongUrl.call(url)
    expect(url).to eq("https://github.com/jakobwesthoff/colorizer")
  end

  it "does not lengthen a url that does not need to be lengthened" do
    url = "http://bit.ly/O44xP7"
    stub_request(:head, "http://bit.ly/O44xP7").to_return(:status => 200)

    url = LongUrl.call(url)
    expect(url).to eql("http://bit.ly/O44xP7")
  end

  it "does not blow up on bad requests" do
    stub_request(:head, "http://bit.ly/O44xP7").to_return(:status => 406)
    url = LongUrl.call("http://bit.ly/O44xP7")
    expect(url).to be_nil
  end

  it "does not blow up on server errors" do
    stub_request(:head, "http://bit.ly/O44xP7").to_return(:status => 500)
    url = LongUrl.call("http://bit.ly/O44xP7")
    expect(url).to be_nil
  end

  it "should follow multiple redirects" do
    stub_redirect("http://short.url/1", "http://short.url/2")
    stub_redirect("http://short.url/2", "http://longurl.com/")
    stub_request(:head, "http://longurl.com/").to_return(:status => 200)

    result = LongUrl.call("http://short.url/1")
    expect(result).to eq("http://longurl.com/")
  end

  it "does not blow up on urls without a trailing slash" do
    stub_redirect("http://short.url", "http://longurl.com")
    stub_request(:head, "http://longurl.com").to_return(:status => 200)
    result = LongUrl.call("http://short.url")
    expect(result).to eq("http://longurl.com")
  end

  # This isn't really testing anything =/ Just the abilty to mock ssl
  it "does not blow up on https requests" do
    stub_request(:head, "https://short.url/")
    result = LongUrl.call("https://short.url/")
  end

  # it "will not follow redirects forever" do
  #
  # end

  # it "determines if the final site is alive" do
  #
  # end

  protected

  def stub_redirect(url, location, response_code = 301)
    stub_request(:head, url).to_return({
      :status => response_code,
      :headers => { "Location" => location }
    })
  end

end
