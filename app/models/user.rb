class User < ActiveRecord::Base
  # Kdyz smazeme uzivatele, odstrani se i jeho microposty
  has_many :microposts, dependent: :destroy
  # Many-to-many mezi uzivateli - koho sleduji
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed

  # Kdo sleduje mne
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  # Tady source ani neni potreba, followers > follower > follower_id coz relationship ma
  has_many :followers, through: :reverse_relationships, source: :follower
	# Nektere DB adaptery maji indexy case insensitive, coz by vadilo pri validoani unikatnosti
	before_save { email.downcase! }
  before_create :create_remember_token

	validates :name,  presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                  uniqueness: { case_sensitive: false }

  # Magie - vytvari virtualni sloupce password a password_confirmation - ty jsou
  # jen v pameti a do DB se neukladaji, pridava take validace na presence a dalsi veci
  has_secure_password

  validates :password, length: { minimum: 6 }

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def feed
    Micropost.from_users_followed_by(self)
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy!
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
