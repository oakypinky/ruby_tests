require './credit_card_checker'

if ARGV.empty?
  p 'You should pass credit card number in params'
else
  ccc = CreditCardChecker.new
  ARGV.each do |code|
    p [code, ccc.valid?(code)]
  end
end
