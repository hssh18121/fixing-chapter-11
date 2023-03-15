class User < ApplicationRecord
    attr_accessor :remember_token, :activation_token
    before_save :downcase_email
    before_create :create_activation_digest

    before_save { self.email = email.downcase }
    validates :name, presence: true, length: { maximum: Settings.max_user_name_length }
    validates :email, presence: true, length: { maximum: Settings.max_user_email_length }, format: { with: Settings.valid_email_regex }, uniqueness: { case_sensitive: false }

    has_secure_password
    validates :password, presence: true, length: { minimum: Settings.min_user_password_length}

    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    def User.new_token
        SecureRandom.urlsafe_base64
    end

    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
        return true
    end

    def forget
        update_attribute(:remember_digest, nil)
    end

    def activate
        update_columns(activated: true, activated_at: Time.now)
    end

    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    private
    # Converts email to all lowercase.
        def downcase_email
            self.email = email.downcase
        end
    # Creates and assigns the activation token and digest.
        def create_activation_digest
            self.activation_token = User.new_token
            self.activation_digest = User.digest(activation_token)
        end
end
