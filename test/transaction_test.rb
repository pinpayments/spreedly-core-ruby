require 'test_common'

module SpreedlyCore
  class TransactionTest < Test::Unit::TestCase
    include TestCommon

    def test_not_found_transaction
      assert_raises InvalidResponse do
        Transaction.find("NOT-FOUND")
      end
    end

    def test_find_returns_retain_transaction_type
      retain = given_a_retained_transaction
      assert_find_transaction(retain, RetainTransaction)
    end

    def test_find_returns_redact_transaction_type
      redact = given_a_redacted_transaction
      assert_find_transaction(redact, RedactTransaction)
    end

    def test_find_returns_authorize_transaction_type
      authorize = given_an_authorized_transaction
      assert_find_transaction(authorize, AuthorizeTransaction)
    end

    def test_find_returns_purchase_transaction_type
      purchase = given_a_purchase
      assert_find_transaction(purchase, PurchaseTransaction)
    end

    def test_find_returns_capture_transaction_type
      capture = given_a_capture
      assert_find_transaction(capture, CaptureTransaction)
    end

    def test_find_returns_voided_transaction_type
      void = given_a_capture_void
      assert_find_transaction(void, VoidedTransaction)
    end

    def test_find_returns_credit_transaction_type
      credit = given_a_capture_credit
      assert_find_transaction(credit, CreditTransaction)
    end

    def test_merchant_descriptor_purchase
      purchase = given_a_purchase({
        :merchant_name_descriptor => 'ACME Inc',
        :merchant_location_descriptor => 'http://acme.org'
      })

      txn = Transaction.find(purchase.token)
      assert_equal 'ACME Inc', txn.merchant_name_descriptor
      assert_equal 'http://acme.org', txn.merchant_location_descriptor
    end

    protected

    def assert_find_transaction(trans, expected_class)
      assert actual = Transaction.find(trans.token)
      assert_equal expected_class, actual.class
    end
  end
end
