class Micropost < ActiveRecord::Base
	belongs_to :user
	default_scope -> { order('created_at DESC') }
	validates :content, presence: true, length: { maximum: 140 }
	validates :user_id, presence: true

	def self.from_users_followed_by(user)
		# Tahle magie je vlastne: user.followed_users.map(&:id), fungovalo by to, ale tohle si vytahn do pameti vsechna
		# id uzivatelu, at jich je kolik chce. To my ctit nebudeme a tak pouzijeme subselect
    	# followed_user_ids = user.followed_user_ids
    	followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
   	 	where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
          user_id: user.id)
  	end
end
