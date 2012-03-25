require 'digest/sha1'
include Geokit::Geocoders

class User < ActiveRecord::Base

  include Bloget::Models::Poster
  acts_as_commentable


  def interesting_posts
    @posts = []
    for t in self.tags
      @posts = @posts + Post.has_tags(t.name)
    end
    return @posts.uniq.last(5).sort{ |a, b| b.created_at <=> a.created_at }
  end

  def friends_posts
    @posts = []
    for f in self.friends
      @posts = @posts + f.posts
    end
    return @posts.uniq.last(5).sort{ |a, b| b.created_at <=> a.created_at }
  end
  
  def clean_activities
    act = self.activities
    for a in act
      for b in act
        if (b.activity_type == a.activity_type) && (b.activity_id == a.activity_id) && (b.id != a.id)
          b.destroy
        end
      end
    end
  end

  def active_date
    if self.profile_updated_at
      self.profile_updated_at
    else
      self.created_at
    end
  end

  has_many_friends
  has_private_messages
  acts_as_taggable
  has_many :requests
  has_many :activities
  has_friendly_id :login

  named_scope :age_gte, lambda { |a| { :conditions => ['birthday < ?', a.to_i.years.ago]}}
  named_scope :age_lte, lambda { |a| { :conditions => ['birthday > ?', a.to_i.years.ago] }}

  named_scope :mentors, :conditions => ['mentoring = 1']
  
  named_scope :name_like, lambda { |a| { :conditions => ["LOWER(first_name || ' ' || last_name) LIKE ?", '%' + a.to_s + '%'] }}

  named_scope :has_tags, lambda {  |tags|
    User.find_options_for_find_tagged_with(tags, :match_all => true)
  }

  has_attached_file :avatar, 
                    :styles => {  :big => "300x300>",
    :medium => "200x200#",
  :thumb => "100x100#", :small => "50x50#", :verysmall => "24x24#" },
  :storage => :s3, # ENV['S3_BUCKET'], # ? :s3 : :filesystem,
  :s3_credentials => { 
  :access_key_id => ENV['S3_KEY'],
  :secret_access_key => ENV['S3_SECRET'],
    :bucket => 'media.stemming.org'}, #ENV['S3_BUCKET']},
  :path => ":id-:style.:extension",
  :default_url => "/images/stemming-default-user-:style.png",
  :rounded => 10

  acts_as_textiled :bio, :education, :career
  acts_as_mappable

  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_protected :admin

  validates_exclusion_of :login, :in => ["admin", "root", "superuser", "webmaster", "search", "invite", "forgot_password", "change_password", "reset_password", "request_friendship", "accept_friendship", "decline_friendship", "cancel_friendship"]

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..16
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of       :login, :with => /^[a-z0-9._ \-]*$/i, :message => "has bad characters"
  validate :valid_email?
  before_save :encrypt_password, :save_location

#  after_save :update_tags



  def sanitized_bio
    Sanitize.clean(self.bio, :elements => ['sup', 'a', 'span', 'b', 'i', 'strong', 'em', 'u', 'ins', 'ul', 'ol', 'li', 'embed', 'p', 'object', 'param', 'img', 'code', 'pre', 'blockquote', 'h4', 'h5'], :attributes => { 'img' => ['src', 'alt', 'style'], 'embed' => ['src', 'type', 'width', 'height'], :object => ['width', 'height'], :param => ['name', 'value'], :p => ['style'], 'a' => ['href', 'title'] }, :protocols => { 'a' => { 'href' => ['http', 'https', 'mailto', :relative]}})
  end

  def sanitized_education
    Sanitize.clean(self.education, :elements => ['sup', 'a', 'span', 'b', 'i', 'strong', 'em', 'u', 'ins', 'ul', 'ol', 'li', 'embed', 'p', 'object', 'param', 'img', 'code', 'pre', 'blockquote', 'h4', 'h5'], :attributes => { 'img' => ['src', 'alt', 'style'], 'embed' => ['src', 'type', 'width', 'height'], :object => ['width', 'height'], :param => ['name', 'value'], :p => ['style'], 'a' => ['href', 'title'] }, :protocols => { 'a' => { 'href' => ['http', 'https', 'mailto', :relative]}})
  end

  def sanitized_career
    Sanitize.clean(self.career, :elements => ['sup', 'a', 'span', 'b', 'i', 'strong', 'em', 'u', 'ins', 'ul', 'ol', 'li', 'embed', 'p', 'object', 'param', 'img', 'code', 'pre', 'blockquote', 'h4', 'h5'], :attributes => { 'img' => ['src', 'alt', 'style'], 'embed' => ['src', 'type', 'width', 'height'], :object => ['width', 'height'], :param => ['name', 'value'], :p => ['style'], 'a' => ['href', 'title'] }, :protocols => { 'a' => { 'href' => ['http', 'https', 'mailto', :relative]}})
  end



  def self.per_page
    10
  end

  def self.paged_find_tagged_with(tags, args = { })
    if tags.blank?
      paginate args
    else
      options = find_options_for_find_tagged_with(tags, :match_all => true)
      options.merge!(args)
      # The default count query generated by paginate includes COUNT(DISTINCT Posts.*) which errors, at least on mysql
      # Below we override the default select statement used to perform the count so that it becomes COUNT(DISTINCT Posts.id)
      paginate(options.merge(:count => {  :select => options[:select].gsub('*', 'id') }))
    end
  end

  def selected_tag_sentence
    if self.tags.size > 16
      return (self.tags.sort_by{rand}.first(16).sort_by{ |t| t.name}.collect{ |i| "<a href='/users/browse/#{ i.name}'>" + i.name + "</a>" } << "<a href='/users/#{self.login}'>more</a>").to_sentence
    else
      return self.tags.collect{ |i| "<a href='/users/browse/#{ i.name}'>" + i.name + "</a>" }.sort.to_sentence
    end
  end


  def full_name
    if self.first_name
      self.first_name + ' ' + self.last_name
    else
      self.last_name
    end
  end

  def next_step?
    self.avatar_file_name.blank? || (self.city.blank? && self.zip.blank?) || self.education.blank? || self.bio.blank? || self.career.blank? || self.tags.blank? || self.posts.blank? || self.friends.size < 3
  end

  def pronoun(dec)
    if dec == 'obj'
      if self.gender == 'Female'
        return 'her'
      elsif self.gender == 'Male'
        return 'him'
      else
        return 'them'
      end
    elsif dec == 'gen'
      if self.gender == 'Female'
        return 'her'
      elsif self.gender == 'Male'
        return 'his'
      else
        return 'their'
      end
    elsif dec == 'subj'
      if self.gender == 'Female'
        return 'she'
      elsif self.gender == 'Male'
        return 'he'
      else
        return 'they'
      end

    end
  end


  def received_requests
    Request.find_all_by_recipient_id(self.id)
  end

  def unread_requests?
    if self.received_requests.find_all{ |r| !(r.read)}.empty?
      return false
    else
      return true
    end
  end

  def unread_request_count
    self.received_requests.find_all{ |r| !(r.read)}.size
  end

  def location_string
    if !self.zip.blank?
      self.zip.to_s
    elsif (!self.city.blank? && !self.state.blank?)
      self.city + ', ' + self.state
    elsif (!self.city.blank? && !self.country.blank?)
      self.city + ', ' + self.country
    elsif !self.city.blank?
      self.city
    elsif !self.state.blank?
      self.state
    elsif !self.country.blank?
      self.country
    else
      nil
    end
  end

  def friends_posts_and_comments
    @posts = self.friends.map { |f| f.posts }.flatten
    @comments = @posts.map { |p| p.comments }.flatten
    return @posts.concat(@comments)
  end

  def friends_comments
    self.friends.map { |f| f.comments }.flatten
  end

  def friends_friendships
    @friendships = self.friends.map{ |u| u.friends.map{ |f| f.friendship(u) }}.flatten
  end


  def friends_activity
    @activity = self.activities
    @activity = @activity.delete_if { |x| x.item.nil? || x.item.active_date.nil? }
    @activity = @activity.map{ |a| a.item }.sort_by{ |a| a.active_date }.reverse.first(30)
  end


  #geocode based on the address info they provided
  def save_location
    if self.location_string
      res = MultiGeocoder.geocode(self.location_string)
    end
    if res
      self.lat = res.lat
      self.lng = res.lng
    end
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def self.update_activity_levels
    for u in self.find(:all)
      u.update_attribute(:activity_level, u.friends.size + (u.posts.size * 4) + (u.comments.size * 3) + (u.post_comment_size * 2) + u.user_comments.size + (u.posts.find_all{ |p| p.front_page? }.size) + UserComment.find_all_by_user_id(u.id).size)
    end
  end

  def post_comment_size
    total = 0
    for p in self.posts
      total += p.comments.size
    end
    return total
  end

  def age
    now = Time.now.utc
now.year - birthday.year - (birthday.to_time.change(:year => now.year) > now ? 1 : 0)
  end

  def age_range
    case self.age
    when 13..18
      "teenager"
    when 18..21
      "college-age"
    when 22..25
      "in #{self.pronoun('gen')} mid-twenties"
    when 26..29
      "in #{self.pronoun('gen')} late twenties"
    when 30..39
      "in #{self.pronoun('gen')} thirties"
    when 40..49
      "in #{self.pronoun('gen')} forties"
    when 50..59
      "in #{self.pronoun('gen')} fifties"
    when 60..69
      "in #{self.pronoun('gen')} sixties"
    when 70..79
      "in #{self.pronoun('gen')} seventies"
    when 80..89
      "in #{self.pronoun('gen')} eighties"
    when 90..99
      "in #{self.pronoun('gen')} nineties"
    when 100..120
      "over a hundred!!"
    end
  end

  def recommended_friends
    @users = Array.new
    if self.location_string.blank?
      @users = User.find(:all)
      @users.delete(self)
      @users = @users - self.friends
      @users = @users - self.pending_friends
    else
      begin
        @users = User.find(:all, :origin => self.location_string, :within => 10)
        @users.delete(self)
        @users = @users - self.friends
        @users = @users - self.pending_friends
        if @users.size < 3
          @users = User.find(:all, :origin => self.location_string, :within => 25)
          @users.delete(self)
          @users = @users - self.friends
          @users = @users - self.pending_friends
          if @users.size < 3
            @users = User.find(:all, :origin => self.location_string, :within => 35)
            @users.delete(self)
            @users = @users - self.friends
            @users = @users - self.pending_friends
            if @users.size < 3
              @users = User.find(:all, :origin => self.location_string, :order => 'distance')
              @users.delete(self)
              @users = @users - self.friends
              @users = @users - self.pending_friends
            end
          end
        end
      rescue
      end
    end
    if @users.size > 3
      @newusers = @users.find_all{ |u| (u.tags & self.tags) != []}
      if @newusers.size >= 3
        @users = @newusers
      end
    end
    @users = @users.sort_by{ rand}
    return @users.first(3)
  end

  def name
    login
  end
 
  def attribution_slug
    "<a href='/users/#{login}' class='slug'><img src='#{ avatar.url(:verysmall)}' alt='' /> #{ login }</a>"
  end


  def forgot_password
    self.make_password_reset_code
    UserNotifier.deliver_forgot_password(self)
  end
  
  def reset_password
    update_attributes(:password_reset_code => nil)
  end
  
  
  
  protected
  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by { rand}.join )
  end
  
  def valid_email?
    TMail::Address.parse(email)
  rescue
    errors.add_to_base("Must be a valid email")
  end

    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end
