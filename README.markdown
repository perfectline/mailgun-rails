### Installation

Add the following to your Gemfile:

    gem 'mailgun-rails'

### Configuration

    config.action_mailer.delivery_method = :mailgun
    config.action_mailer.mailgun_settings = {
        :api_key  => "YOUR_API_KEY",
        :api_host => "YOUR_API_HOST"
    }
