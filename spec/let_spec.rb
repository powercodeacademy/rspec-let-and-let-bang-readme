
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

  it 'has a pending spec for students: override let for a large Mocha order' do
    pending('Override let to create a large Mocha order and test its drink and size')
    raise 'Not implemented'
    # let(:order) { CoffeeOrder.new('Mocha', 'large') }
    # expect(order.drink).to eq('Mocha')
    # expect(order.size).to eq('large')
  end

  it 'has a pending spec for students: use let! to serve an order and check status' do
    pending('Use let! to serve an order before the example and test that status is :served')
    raise 'Not implemented'
    # let!(:served_order) { order.serve; order }
    # expect(served_order.status).to eq(:served)
  end
end
