class UserComment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  
  # NOTE: install the acts_as_votable plugin if you 
  # want user to vote on the quality of comments.
  #acts_as_voteable
  after_save :create_activities

  def active_date
    self.created_at
  end

  def create_activities
    for u in (User.find(self.user_id).friends).concat(User.find(self.commentable_id).friends).uniq
      Activity.create(:activity_id => self.id, :activity_type => 'user_comment', :user_id => u.id)
    end
  end

  def sanitized_content
    Sanitize.clean(self.comment, :elements => ['a', 'span', 'b', 'i', 'strong', 'em', 'u', 'ins', 'ul', 'ol', 'li', 'embed', 'p', 'object', 'param', 'img', 'code', 'blockquote', 'h4'], :attributes => { 'embed' => ['src', 'type', 'width', 'height'], :object => ['width', 'height'], :param => ['name', 'value'], :p => ['style'], 'a' => ['href', 'title'] }, :protocols => { 'a' => { 'href' => ['http', 'https', 'mailto', :relative]}})
  end
  
  # NOTE: Comments belong to a user
#  belongs_to :user
  def user
    User.find(self.user_id)
  end
  
  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  def self.find_comments_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end
  
  # Helper class method to look up all comments for 
  # commentable class name and commentable id.
  def self.find_comments_for_commentable(commentable_str, commentable_id)
    find(:all,
      :conditions => ["commentable_type = ? and commentable_id = ?", commentable_str, commentable_id],
      :order => "created_at DESC"
    )
  end

  # Helper class method to look up a commentable object
  # given the commentable class name and id 
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end
end
