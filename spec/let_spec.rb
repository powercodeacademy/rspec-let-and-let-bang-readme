
require_relative '../lib/coffee_order'
require_relative '../lib/cafe'

RSpec.describe 'let and let! with CoffeeOrder and Cafe' do
  let(:order) { CoffeeOrder.new('Latte', 'medium') }
  let(:cafe) { Cafe.new }

  let(:status) { order.status }
  let!(:prepared_order) { order.prepare; order }

  it 'uses let to lazily create a CoffeeOrder' do
    expect(order.drink).to eq('Latte')
    expect(order.size).to eq('medium')
  end

  it 'uses let! to eagerly prepare the order' do
    expect(prepared_order.status).to eq(:prepared)
  end

  it 'memoizes let values within an example' do
    expect(order).to equal(order)
  end


  context 'when overriding let in a nested context' do
    let(:order) { CoffeeOrder.new('Espresso', 'small') }
    it 'uses the overridden order' do
      expect(order.drink).to eq('Espresso')
      expect(order.size).to eq('small')
    end
  end

  context 'with a served order' do
    let!(:served_order) { order.serve; order }
    it 'marks the order as served' do
      expect(served_order.status).to eq(:served)
      expect(served_order.served?).to eq(true)
    end
  end

  it 'uses let for a Cafe and checks if it is open' do
    expect(cafe.open?).to eq(true)
  end

  it 'uses let to brew a drink' do
    expect(cafe.brew('Cappuccino')).to eq('Brewing Cappuccino...')
  end

  it 'uses let! to prepare an order before the example' do
    expect(prepared_order.prepared?).to eq(true)
  end

  context 'when overriding drink order in nested context' do
    let(:order) { CoffeeOrder.new('Mocha', 'large') }
    it 'override let for a large Mocha order' do
      expect(order.drink).to eq('Mocha')
      expect(order.size).to eq('large')
    end
  end

  context 'when overriding let! is nested context' do
    let!(:served_order) { order.serve; order }
    it 'use let! to serve an order and check status' do
      expect(served_order.status).to eq(:served)
    end
  end
end
