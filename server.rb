require 'rubygems'
require 'bundler'

Bundler.require

use Rack::Deflater
use Rack::Csrf

enable :sessions
set :bind, '0.0.0.0'
set :session_secret,          ENV['secret']
set :slack_invite_api_url,    'https://slack.com/api/users.admin.invite'
set :background_color,        ENV.fetch('BACKGROUND_COLOR', '#E4D6C8')
set :text_color,              ENV.fetch('TEXT_COLOR', '#FDFCFB')
set :email_background_color,  ENV.fetch('EMAIL_BACKGROUND_COLOR', '#FDFCFB')
set :email_text_color,        ENV.fetch('EMAIL_TEXT_COLOR', '#737373')
set :button_color,            ENV.fetch('BUTTON_COLOR', '#F39C12')
set :button_hover_color,      ENV.fetch('BUTTON_HOVER_COLOR', '#D78D19')
set :button_text_color,       ENV.fetch('BUTTON_TEXT_COLOR', '#FDFCFB')
set :team_name,               ENV.fetch('SLACK_TEAM_NAME', 'VFK1')
set :team_desc,               ENV.fetch('SLACK_TEAM_DESC', '자동가입. By Jason Kim')

helpers do
  def invite_request_to_slack
    response = Excon.post(settings.slack_invite_api_url,
                body: URI.encode_www_form(
                        token: ENV['xoxp-3695627691-3695627707-3807818244-7a9ab8'],
                        email: @email,
                        set_active: true
                      ),
                headers: { "Content-Type" => "application/x-www-form-urlencoded" })
    @result = response.status == 200 && MultiJson.load(response.body)["ok"]
    logger.info { response.body } unless @result
    @result
  end
end

get '/' do
  erb :index
end

post '/invite' do
  @email = params[:email]
  @result = invite_request_to_slack
  erb :invite
end
