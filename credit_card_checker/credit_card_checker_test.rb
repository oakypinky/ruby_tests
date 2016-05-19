require 'test/unit'
require './credit_card_checker'

class CreditCardCheckerTest < Test::Unit::TestCase
  def setup
    @ccc = CreditCardChecker.new

    @cc_codes = [
      {code: 645100_1234567690,   valid: true,  luhn: true,  issuer: "Discover"},
      {code: 400100_1234567492,   valid: true,  luhn: true,  issuer: "Visa",},
      {code: 550000_1234567891,   valid: true,  luhn: true,  issuer: "Mastercard",},
      {code: 370000_623456789,    valid: true,  luhn: true,  issuer: "American Express"},
      {code: 370000_1234567894,   valid: false, luhn: true}, # wrong code length
      {code: 340000_623456789,    valid: false, luhn: false, issuer: "American Express"},
      {code: "340dfg62345678",    valid: false},
      {code: "400100_1234567492", valid: true,  luhn: true,  issuer: "Visa"},
      {code: "370000_623456789a", valid: false},
    ]
  end

  def test_credit_card_numbers
    @cc_codes.each do |cc_info|
      assert_equal cc_info[:valid], @ccc.valid?(cc_info[:code])
    end
  end

  def test_credit_card_numbers_verbose
    @cc_codes.each do |cc_info|
      result = @ccc.verbose_validation cc_info[:code]
      assert_equal cc_info[:valid], result[:valid]
      assert_equal cc_info[:issuer], result[:issuer]
      assert_equal cc_info[:luhn], result[:luhn]
    end
  end
end
