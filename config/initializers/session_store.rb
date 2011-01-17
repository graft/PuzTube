# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_puztube_session',
  :secret      => 'ccd2eea9606a6c5074aa0b897a2d4cd9fbb16f97c94e5f21102d8ebd734c7c9c693a0f43fd25deb68af356ff0ef1fb863b913f7fdd14d3acaf5f4dd94afcb4cd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
