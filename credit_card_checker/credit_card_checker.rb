require './bank_data'

# Class provides methods for validation of credit card numbers based on luhn algorithm
#   and specific bank information like IIN ranges and code lengthes.
# Specific bank data is stored in bank_data.rb.

class CreditCardChecker

  # Method accepts string or int code numbers.
  # String versions can contain '_' separators as code is converted to_i.to_s first.
  # It returns true if card number passed luhn check and if IIN and code length
  #   matches any registered bank in bank_data.rb.
  # False is returned when card number fails validation or when invalid input is provided.

  def valid?(code)
    code = validate_input(code)
    return false if code.nil?
    valid_luhn?(code) && valid_bank?(code[0, 6], code.size)
  end

  # Method to provide more concrete information about number like why check fails -
  #   because of a luhn algorithm failure of because bank validation.
  # Also provides issuer name if bank check succeded.

  def verbose_validation(code)
    code = validate_input(code)
    return {valid: false} if code.nil?

    bank = bank(code[0, 6], code.size)
    result = {
      luhn: valid_luhn?(code),
      issuer: bank ? bank[:issuer] : nil
    }
    result[:valid] = (result[:luhn] && !bank.nil?)
    result
  end

  private

    # Method assumes Int codes and String codes that looks like Int as valid.
    # For example "123_456_789" is a valid String code.
    # While "123_456_789a" is not.

    def validate_input(code)
      if code.is_a?(Integer)
        code.to_s
      elsif code.is_a?(String) && code.gsub('_', '').size == code.to_i.to_s.size
        code.to_i.to_s
      end
    end

    def valid_luhn?(code)
      luhn_checksum(code) == 0
    end

    # Method accepts code number in string format.
    # Calculates luhn checksum (sum % 10) for the provided code number.

    def luhn_checksum(code)
      digits = code.chars.map(&:to_i)
      digits.reverse.each_with_index.reduce(0) do |sum, (digit, index)|
        sum +=
          case
          when index.even? then digit
          when digit < 5 then digit * 2
          else digit * 2 - 9
          end
      end % 10
    end

    def valid_bank?(iin, length)
      !bank(iin, length).nil?
    end

    # Method returns hash with bank information based on provided IIN and code length.
    # If no bank is specified in bank_data.rb for provided parameters then nil is returned.

    def bank(iin, length)
      CREDIT_CARDS.each do |info|
        length_masks = [*info[:length]]
        iin_masks = [*info[:IIN]]
        return info if length_masks.include?(length) && match_iin?(iin, iin_masks)
      end
      nil
    end

    # Checks in IIN is within range of any of provided IIN masks.
    # Masks can be in Integer or Range formats.

    def match_iin?(iin, iin_masks)
      iin_masks.each do |mask|
        return true if mask.is_a?(Integer) && iin.start_with?(mask.to_s)

        if mask.is_a?(Range)
          mask.each { |value| return true if iin.start_with?(value.to_s) }
        end
      end
      false
    end

end
