# Class takes a filepath of dictionary file and processes it into a list
#   of word pairs whereby swapping the last (default 2) letters of the word
#   results in another valid word.
# As checking for presence of each misspelled word inside whole dictionary
#   proved to be quite time consuming operation, more verbose approach was
#   taken to get around this issue.
class DictionarySearch
  # Constant used to regulate the length of fragment that can be reversed.
  POSTFIX_LENGTH = 2

  attr_reader :word_pairs

  def initialize(dictionary_filename)
    @word_pairs = []
    form_pairs read_words dictionary_filename
  end

  private

    # Reads words from dictionary provided as a filepath.
    # It is assumed that each line contains only single word.
    # Returns array with trimmed words or empty array if bad filename is passed.

    def read_words(dictionary)
      unless FileTest.file?(dictionary)
        p "Provided #{dictionary} is not a filepath or such file doesn't exist."
        return []
      end

      words = []
      IO.foreach(dictionary) { |line| words << line.strip }
      words
    end

    # Processes and writes pairs of words into instance variable @word_pairs.
    # Algorithm in general:
    # * split all list of words into groups containing similar enough words,
    #   similar enough means that words in group have same length and are equal
    #   except for number of POSTFIX_LENGTH symbols in the end;
    # * for each group for each word make a misspelled one and add this pair if
    #   words differ, if misspelled word exists in current group and if
    #   such pair in different order already not in the list.

    def form_pairs(words)
      split_in_similar_groups(words).each do |similar_words|
        similar_words.each do |word|
          misspelled_word = same_part(word) + misspelled_part(word)
          if word != misspelled_word &&
             similar_words.include?(misspelled_word) &&
             !@word_pairs.include?([misspelled_word, word])
            @word_pairs << [word, misspelled_word]
          end
        end
      end
    end

    # Splits list of words into groups containing similar enough words.
    # First, words that are as POSTFIX_LENGTH or shorter are filtered.
    # Next, words are sorted by length and splitted into groups of words
    #   of the same length.
    # And than each group is sorted alphabetically and splitted into
    #   groups of words having the same first part. All such groups are
    #   concatenated into similar_groups that this method returns.

    def split_in_similar_groups(words)
      words.select! { |word| word.size > POSTFIX_LENGTH }
      words.sort! { |a, b| a.size <=> b.size }

      split_by_condition(words, lambda { |a, b| a.size == b.size }).flat_map do |same_word_length_group|
        split_by_condition(same_word_length_group.sort,
                           lambda { |a, b| same_part(a) == same_part(b) })
      end
    end

    # Helper method that splits an array by provided condition.
    # By default it will not add a single element groups into resulting list.

    def split_by_condition(array, condition, omit_single_element_groups = true)
      groups = []
      group = []

      until array.empty?
        element = array.shift
        if group.empty? || condition.call(group[0], element)
          group << element
        else
          groups << group unless omit_single_element_groups && group.size == 1
          group = [element]
        end
      end
      groups
    end

    def same_part(word)
      word[0, word.size - POSTFIX_LENGTH]
    end

    def misspelled_part(word)
      word[-POSTFIX_LENGTH, POSTFIX_LENGTH].reverse
    end
end
