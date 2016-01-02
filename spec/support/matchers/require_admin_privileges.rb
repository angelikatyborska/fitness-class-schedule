RSpec::Matchers.define :require_admin_privileges do
  match do |actual|
    expect(actual).to raise_error ActionController::RoutingError
  end

  supports_block_expectations

  failure_message do |actual|
    'expected to require admin privileges to access the method'
  end

  failure_message_when_negated do |actual|
    'expected not to require admin privileges to access the method'
  end

  description do
    'raise ActionController::RoutingError'
  end
end