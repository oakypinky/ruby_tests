require './credit_card_checker'

if ARGV.empty?
  p 'You should pass credit card number in params'
else
  ARGV.each do |code|
    p [code, CreditCardChecker.valid?(code)]
  end
end
