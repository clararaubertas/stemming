class Friendship < ActiveRecord::Base

  belongs_to :friendshipped_by_me,   :foreign_key => "user_id",   :class_name => "User"
  belongs_to :friendshipped_for_me,  :foreign_key => "friend_id", :class_name => "User"
  
  after_save :create_activities

  # TODO: Add some friendly accessor methods here
  def active_date
    self.accepted_at
  end

  def create_activities
    for u in (User.find(self.user_id).friends.concat(User.find(self.friend_id).friends)).uniq
      Activity.create(:activity_id => self.id, :activity_type => 'friendship', :user_id => u.id)
      u.clean_activities
    end
  end

end

