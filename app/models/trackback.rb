require 'net/http'
require 'uri'
require 'hpricot'
require 'open-uri'

# Simple trackback class to send a trackback to another weblog
# This is used via the console
#
# Example:
# >> t = Trackback.new("theadmin.org", 227)
# >> t.send('http://trackback.example/url.php?1234')
#
class Trackback

  @data = { }

  def initialize(id)

    post = Post.find(id)

    if post.nil?
      raise "Could not find article"
    end

    if post.published_at.nil?
      raise "Article not published"
    end

    @data =  {
      :title => post.title,
      :excerpt => post.excerpt,
      :url => "http://stemming.org/posts/" + post.permalink,
      :blog_name => post.title + " :: stemming.org"
    }
  end

  def send(url)
    trackback_url = discover(url)
    unless trackback_url.nil?
      u = URI.parse trackback_url
      begin
      res = Net::HTTP.start(u.host, u.port) do |http|
        http.post(u.request_uri, url_encode(@data), { 'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8' })
      end
      rescue
        return nil
      end
      RAILS_DEFAULT_LOGGER.info "TRACKBACK: #{trackback_url} returned a response of #{res.code} (#{res.body})"
      return res
    else
      return nil
    end
  end

  private

  def discover(url)
    begin
      doc = Hpricot(open(url))
      if doc.at("a[@rel='trackback']")
        return doc.at("a[@rel='trackback']")['href']
      else
        return nil
      end
    rescue
      return nil
    end
  end

  def url_encode(data)
    return data.map {|k,v| "#{k}=#{v}"}.join('&').gsub(' ', '+')
  end


end
