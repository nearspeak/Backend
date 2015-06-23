##
# The Customer model handles customers.
class Customer < ActiveRecord::Base
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :lockable,
         :omniauthable,
         :confirmable

  validates_inclusion_of :cms_lang, :in => CustomersHelper.supported_cms_languages

  has_many :tag_categories
  has_many :authorizations, dependent: :destroy

  ##
  # Get the full customer name
  def get_customer_name
    first_name + ' ' + last_name
  end

  ##
  # Generate a new authentication token for the customer.
  def ensure_authentication_token
    authorization = Authorization.where(:provider => 'devise', :customer_id => id.to_s).first_or_initialize

    if authorization.token.blank?
        #generate new token
        authorization.token = Devise.friendly_token
    end

    authorization.save
  end

  ##
  # Get the authentication token for the customer.
  def get_devise_auth_token
    authorization = Authorization.where(:provider => 'devise', :customer_id => id.to_s).first

    unless authorization.blank?
      authorization.token
    end
  end

  ##
  # Remove the authentication token for the customer.
  #
  # @param authentication_token [String] The authentication token.
  def remove_devise_auth_token(authentication_token)
    authorization = Authorization.where(:provider => 'devise', :token => authentication_token).first

    unless authorization.blank?
      if authorization.destroy
        return true
      end
    end

    return false
  end

  ##
  # Get the customer object via the authentication token.
  # 
  # @param authentication_token [String] The authentication token.
  def self.find_by_auth_token(authentication_token)
    authorization = Authorization.where(:provider => 'devise', :token => authentication_token).first

    unless authorization.blank?
      unless authorization.customer.blank?
        authorization.customer
      end
    end
  end

  ##
  # Create a new session.
  #
  # @param params [Symbol] The parameters.
  # @param session [Symbol] The session.
  def self.new_with_session(params, session)
    if session['devise.user_attributes']
      new(session['devise.user_attributes'], without_protection: true) do |customer|
        customer.attributes = params
        customer.valid?
      end
    else
      super
    end
  end

  ##
  # Authenticate the user via omni auth.
  #
  # @param auth [Symbol] The symbol.
  # @param current_customer [Symbol] The current customer.
  def self.from_omniauth(auth, current_customer)
    authorization = Authorization.where(:provider => auth.provider, :uid => auth.uid.to_s, :token => auth.credentials.token, :secret => auth.credentials.secret).first_or_initialize
    if authorization.customer.blank?
      customer = current_customer.nil? ? Customer.where('email = ?', auth['info']['email']).first : current_customer
      if customer.blank?
        customer = Customer.new
        customer.password = Devise.friendly_token
        customer.first_name = auth['info']['first_name']
        customer.last_name = auth['info']['last_name']
        customer.email = auth.info.email
        auth.provider == 'twitter' ?  customer.save(:validate => false) :  customer.save
      end
      authorization.username = auth.info.nickname
      authorization.customer_id = customer.id
      authorization.save
    end
    authorization.customer
  end

  ##
  # Authenticate the user via facebook.
  #
  # @param auth_toke [Symbol] The authentication token.
  # @param user_data [Symbol] The user data.
  def self.from_facebook(auth_token, user_data)
    authorization = Authorization.where(:provider => 'facebook', :uid => user_data['id'].to_s, :token => auth_token).first_or_initialize

    if authorization.customer.blank?
      customer = Customer.where('email = ?', user_data['email']).first

      if customer.blank?
        customer = Customer.new
        customer.password = Devise.friendly_token
        customer.first_name = user_data['first_name']
        customer.last_name = user_data['last_name']
        customer.email = user_data['email']
        customer.save
      end

      authorization.username = user_data['username']
      authorization.customer_id = customer.id
      authorization.save
    end
    authorization.customer
  end
end