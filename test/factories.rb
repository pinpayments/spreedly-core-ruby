module SpreedlyCore
  module Factory
    def given_a_payment_method(cc_card=:master, card_options={})
      token = SpreedlyCore::PaymentMethod.
        create_test_token(cc_data(cc_card, card_options), "customer-42")
      assert payment_method = SpreedlyCore::PaymentMethod.find(token)
      assert_equal "customer-42", payment_method.data
      assert_equal token, payment_method.token
      payment_method
    end

    def given_a_purchase(options = {})
      defaults = {
        :amount => 100,
        :ip_address => '127.0.0.1'
      }
      options = defaults.merge(options)

      payment_method = given_a_payment_method
      assert transaction = payment_method.purchase(purchase_amount, options[:amount], options)
      assert_equal purchase_amount, transaction.amount
      assert_equal "USD", transaction.currency_code
      assert_equal "Purchase", transaction.transaction_type
      assert_equal ip_address, transaction.ip
      assert transaction.succeeded?
      transaction
    end

    def given_a_retained_transaction
      payment_method = given_a_payment_method
      assert transaction = payment_method.retain
      assert transaction.succeeded?
      assert_equal "RetainPaymentMethod", transaction.transaction_type
      transaction
    end

    def given_a_redacted_transaction
      retained_transaction = given_a_retained_transaction
      assert payment_method = retained_transaction.payment_method
      transaction = payment_method.redact
      assert transaction.succeeded?
      assert_equal "RedactPaymentMethod", transaction.transaction_type
      assert !transaction.token.blank?
      transaction
    end

    def given_an_authorized_transaction(amount=100, ip_address='127.0.0.1')
      payment_method = given_a_payment_method
      assert transaction = payment_method.authorize(100, nil, nil, ip_address)
      assert_equal 100, transaction.amount
      assert_equal "USD", transaction.currency_code
      assert_equal ip_address, transaction.ip
      assert_equal SpreedlyCore::AuthorizeTransaction, transaction.class
      transaction
    end

    def given_a_capture(amount=100, ip_address='127.0.0.1')
      transaction = given_an_authorized_transaction(amount, ip_address)
      capture = transaction.capture(amount, ip_address)
      assert capture.succeeded?
      assert_equal amount, capture.amount
      assert_equal "Capture", capture.transaction_type
      assert_equal ip_address, capture.ip
      assert_equal SpreedlyCore::CaptureTransaction, capture.class
      capture
    end

    def given_a_purchase_void(ip_address='127.0.0.1')
      purchase = given_a_purchase
      assert void = purchase.void(ip_address)
      assert_equal purchase.token, void.reference_token
      assert_equal ip_address, void.ip
      assert void.succeeded?
      void
    end

    def given_a_capture_void(ip_address='127.0.0.1')
      capture = given_a_capture
      assert void = capture.void(ip_address)
      assert_equal capture.token, void.reference_token
      assert_equal ip_address, void.ip
      assert void.succeeded?
      void
    end

    def given_a_purchase_credit(purchase_amount=100, credit_amount=100, ip_address='127.0.0.1')
      purchase = given_a_purchase({:amount => purchase_amount, :ip_address => ip_address})
      given_a_credit(purchase, credit_amount, ip_address)
    end

    def given_a_capture_credit(capture_amount=100, credit_amount=100, ip_address='127.0.0.1')
      capture = given_a_capture(capture_amount, ip_address)
      given_a_credit(capture, credit_amount, ip_address)
    end

    def given_a_credit(trans, credit_amount=100, ip_address='127.0.0.1')
      assert credit = trans.credit(credit_amount, ip_address)
      assert_equal trans.token, credit.reference_token
      assert_equal credit_amount, credit.amount
      assert_equal ip_address, credit.ip
      assert credit.succeeded?
      assert SpreedlyCore::CreditTransaction, credit.class
      credit
    end



  end
end
