require 'test_common'

module SpreedlyCore
  class ParserTest < Test::Unit::TestCase
    include TestCommon

    def test_parses_message_key
      purchase = given_a_purchase
      assert_not_nil purchase.message_key
      assert_equal "messages.transaction_succeeded", purchase.message_key
    end
  end
end
