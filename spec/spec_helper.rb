require 'colorize'
require 'rspec/its'
require 'timecop'
require 'webmock/rspec'

# ------------------------------------------------------------
# RSpec configuration

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation

  config.expect_with :rspec do |c|
    # force use of "expect" rather than "should" syntax
    c.syntax = :expect
  end

  config.around(:each) do |example|
    WebMock.disable_net_connect!(
      allow_localhost: true,
      # prevent running out of file handles -- see https://github.com/teamcapybara/capybara#gotchas
      net_http_connect_on_start: true
    )
    example.run
  ensure
    WebMock.allow_net_connect!
  end

  # Required for shared contexts (e.g. in ssh_helper.rb); see
  # https://relishapp.com/rspec/rspec-core/docs/example-groups/shared-context#background
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
