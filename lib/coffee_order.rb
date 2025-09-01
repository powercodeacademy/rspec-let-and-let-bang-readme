# lib/coffee_order.rb

class CoffeeOrder
  attr_reader :drink, :size, :status

  def initialize(drink, size)
    @drink = drink
    @size = size
    @status = :ordered
  end

  def prepare
    @status = :prepared
  end

  def serve
    @status = :served
  end

  def prepared?
    @status == :prepared
  end

  def served?
    @status == :served
  end
end
