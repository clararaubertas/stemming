class Request < ActiveRecord::Base
  belongs_to :user

  def recipient
    User.find(self.recipient_id)
  end

  def mark_as_read
    self.update_attribute(:read, true)
  end

end
