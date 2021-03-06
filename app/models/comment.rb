class Comment < ActiveRecord::Base
  include Bloget::Models::Comment
  acts_as_textiled :content
  after_save :queue

  def commentable
    User.find(self.commentable_id)
  end

  def active_date
    self.created_at
  end

  def queue
    self.send_later(:create_activities)
  end

  def create_activities
    for u in (User.find(self.poster_id).friends)
      Activity.create(:activity_id => self.id, :activity_type => 'comment', :user_id => u.id)
      u.clean_activities
    end
  end


  def sanitized_content
    Sanitize.clean(self.content, :elements => ['a', 'span', 'b', 'i', 'strong', 'em', 'u', 'ins', 'ul', 'ol', 'li', 'embed', 'p', 'object', 'param', 'img', 'code', 'blockquote', 'h4'], :attributes => { 'embed' => ['src', 'type', 'width', 'height'], :object => ['width', 'height'], :param => ['name', 'value'], :p => ['style'], 'a' => ['href', 'title'] }, :protocols => { 'a' => { 'href' => ['http', 'https', 'mailto', :relative]}})
  end

  def content_excerpt
    HTML::FullSanitizer.new.sanitize(self.content).split[0..(29)].join(" ") + (HTML::FullSanitizer.new.sanitize(self.content).split.size > 30 ? " <a href='/posts/#{self.post.permalink}#comment_#{self.id.to_s}'>(read more...)</a>" : "")
  end

end
