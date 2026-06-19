puts "hello ruby"
class Calculator
    attr_accessor :name

    def initialize(name)
        @name = name 
    end

    def add(a, b)
    a + b
  end

  def subtract(a, b)
    a - b
  end
end

require 'date'

today = Date.today
puts today  # 今日の日付を表示

next_week = today + 7
puts next_week  # 1週間後の日付を表示
