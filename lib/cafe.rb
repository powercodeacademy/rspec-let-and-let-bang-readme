# lib/cafe.rb

class Cafe
  def open?
    true
  end

  def brew(drink)
    "Brewing #{drink}..."
  end

  def serve(order)
    "Serving #{order.drink} (#{order.size})"
  end
end
