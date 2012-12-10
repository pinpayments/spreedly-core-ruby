require 'test_common'

module SpreedlyCore
  class GatewayTest < Test::Unit::TestCase
    include TestCommon

    def test_gets_all
      tg1 = TestGateway.get_or_create
      all = Gateway.all
      assert all.include?(tg1)

      tg2 = Gateway.create(:gateway_type => 'test')
      all = Gateway.all
      [tg1, tg2].each{|g| assert all.include?(g)}
    end

    def test_create_succeeds_for_test
      assert_nothing_raised InvalidResponse do
        Gateway.create(:gateway_type => 'test')
      end
    end
  end
end
