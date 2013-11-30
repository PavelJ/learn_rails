class User < ActiveRecord::Base
  # Kdyz smazeme uzivatele, odstrani se i jeho microposty
  has_many :microposts, dependent: :destroy
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
    # Vzdy je nutne vyuzit tento zapis pro zdani parametru, hodnota je totiz pak escapovana
    # aby nemohlo dojit k SQL injection
    Micropost.where("user_id = ?", id)
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
