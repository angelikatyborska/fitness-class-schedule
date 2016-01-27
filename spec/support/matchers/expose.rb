require 'pp'

RSpec::Matchers.define :expose do |as, content|
  match do |actual|
    if content.is_a?(Array) || content.is_a?(ActiveRecord::Relation)
      expect(controller.public_send(as)).to match_array content
    else
      expect(controller.public_send(as)).to eq content
    end
  end

  supports_block_expectations

  failure_message do |actual|
    expected = content
    got = controller.public_send(as)

    if content.is_a?(Array) || content.is_a?(ActiveRecord::Relation)
      expected = expected.to_a
      got = got.to_a
    end

    "expected #{ actual } to expose \n\n#{ expected.inspect }\n\nas #{ as }, but #{ as } is \n\n#{ got.inspect }"
  end

  failure_message_when_negated do |actual|
    got = content
    got = got.to_a if content.is_a?(Array) || content.is_a?(ActiveRecord::Relation)

    "expected #{ actual } not to expose \n\n#{ got.inspect }\n\n as #{ as }"
  end

  description do
    "expose #{ as }"
  end
end