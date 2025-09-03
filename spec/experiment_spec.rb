# /spec/experiment_spec.rb
RSpec.describe "let vs let!" do
  let(:lazy) { puts "let runs!" }
  let!(:eager) { puts "let! runs!" }

  it "shows when let and let! run" do
    # Only let! runs so far
    lazy # Now let runs
  end
end
