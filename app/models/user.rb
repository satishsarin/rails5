class User < ApplicationRecord
  extend BackendJobs

  module Timeline
    ITEMS = [MicroBlog, Share].map(&:name).map(&:underscore)
  end

  module ListBy
    ITEMS = [MicroBlog, Like, Comment, Share].map(&:name).map(&:underscore)
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable

  # Associations

  # Validations

  # Callback
  before_save :ensure_auth_token, if: lambda { |entry| entry[:auth_token].blank? }

  # Callback method
  def ensure_auth_token
    self.auth_token = formulate_key
  end

  # Class methods
  class << self
    def from_api_key(api_key, renew = false)
    	self.find_by_auth_token api_key if renew
    end

    def cached_api_key(api_key)
    	self.find_by_auth_token api_key
    end
  end

  # Instance methods
  def generate_api_key
  end

  def fetch_timeline_items(filter_by, current_user_id)
  end

  def convert_to_hashes(contents, current_user_id)
  end

  def owns?(item_id, item_type)
    item_type.constantize.exists?(id: item_id, user_id: id)
  end

  def follows?(user_id)
    followers.pluck(:id).include?(user_id)
  end

  def is_followed_by?(user_id)
    followed_by.pluck(:id).include?(user_id)
  end

  def has_blocked?(user_id)
    blockers.pluck(:id).include?(user_id)
  end

  def has_been_blocked_by?(user_id)
    blocked_by.pluck(:id).include?(user_id)
  end

  def follow(follower_id)
    followers << User.where(id: follower_id).first if id != follower_id
  end

  def unfollow(follower_id)
    followers.delete(User.where(id: follower_id).first)
  end

  def block(blocker_id)
    blockers << User.where(id: blocker_id).first if id != blocker_id
  end

  def unblock(blocker_id)
    blockers.delete(User.where(id: blocker_id).first)
  end

  private
  def formulate_key
    str = OpenSSL::Digest::SHA256.digest("#{SecureRandom.uuid}_#{self.email}_#{Time.now.to_i}")
    Base64.encode64(str).gsub(/[\s=]+/, "").tr('+/','-_')
  end
end
