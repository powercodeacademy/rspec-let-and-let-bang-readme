
# RSpec: let and let! (CoffeeOrder & Cafe Edition)

If you’ve ever wondered, “Is there a better way to set up test data than using instance variables everywhere?”—let us introduce you to `let` and `let!`. These RSpec helpers are like the secret agents of your test suite: they show up only when you need them, keep your specs clean, and sometimes even surprise you with their cleverness. All examples use CoffeeOrder and Cafe for clarity and realism.

---

## Why Use *let* and *let!* Instead of Instance Variables?

Let’s get real: instance variables (`@thing`) are the old-school way to share data in your specs. They work, but they have some sneaky downsides:

- **Always set up, even if you don’t use them.** This can slow down your tests and make it unclear what’s actually needed for each example.
- **Accidental reuse or pollution.** If you change an instance variable in one test, it might affect another (especially with `before(:all)`).
- **Harder to read.** It’s not always obvious where `@calculator` or `@user` came from, especially in big specs.

Enter `let` and `let!`: these helpers make your specs cleaner, clearer, and more efficient. Here’s a quick comparison:

| Feature               | Instance Variable (`@thing`) | `let`                  | `let!`                 |
| --------------------- | ------------------------------ | ------------------------ | ------------------------ |
| When is it set up?    | Before every example           | When first used          | Before every example     |
| Is it always created? | Yes                            | No (lazy)                | Yes (eager)              |
| Can you override it?  | No                             | Yes (in nested contexts) | Yes (in nested contexts) |
| Readability           | Sometimes unclear              | Very clear               | Very clear               |
| Test pollution risk   | Possible                       | Minimal                  | Minimal                  |

### Example: Instance Variables vs *let*

#### Using Instance Variables (the old way)

```ruby
# /spec/coffee_order_spec.rb
RSpec.describe CoffeeOrder do
  before(:each) do
    @order = CoffeeOrder.new('Latte', 'medium')
  end

  it "returns the drink name" do
    expect(@order.drink).to eq('Latte')
  end

  it "returns the size" do
    expect(@order.size).to eq('medium')
  end
end
```

#### Using *let* (the modern way)

```ruby
# /spec/coffee_order_spec.rb
RSpec.describe CoffeeOrder do
  let(:order) { CoffeeOrder.new('Latte', 'medium') }

  it "returns the drink name" do
    expect(order.drink).to eq('Latte')
  end

  it "returns the size" do
    expect(order.size).to eq('medium')
  end
end
```

Notice how `let` makes it clear that `calculator` is a helper method, not a mysterious variable. It’s only created if you use it in the test, which keeps things fast and focused.

### More Benefits of *let*/*let!*

- **Isolation:** Each example gets its own value, so tests can’t accidentally affect each other.
- **Clarity:** It’s easy to see what data is available in each test—just look for the `let` blocks at the top.
- **Flexibility:** You can override `let` in nested `context` blocks to test different scenarios without repeating yourself.

#### Example: Overriding *let* in a context

```ruby
# /spec/coffee_order_spec.rb
RSpec.describe CoffeeOrder do
  let(:order) { CoffeeOrder.new('Latte', 'medium') }

  context "with a default order" do
    it "returns the drink name" do
      expect(order.drink).to eq('Latte')
    end
  end

  context "with a special order" do
    let(:order) { CoffeeOrder.new('Mocha', 'large') }

    it "returns the drink name and size" do
      expect(order.drink).to eq('Mocha')
      expect(order.size).to eq('large')
    end
  end
end
```

Try doing that with instance variables—it gets messy fast!

**How does RSpec resolve which let to use?**

```ruby
RSpec.describe "let resolution" do
  let(:drink) { "Latte" }
  context "outer context" do
    # drink == "Latte"
    context "inner context" do
      let(:drink) { "Mocha" }
      # drink == "Mocha" (overrides outer)
    end
  end
end
```

Resolution order: RSpec looks for the closest let in the current context, then moves outward until it finds one.

## let: Lazy Evaluation and Memoization in Action

With `let`, the value isn’t created until you actually use it in your test. This can make your specs faster and easier to understand. **Bonus:** The value is memoized—multiple calls to the same `let` in a single example return the same object.

```ruby
# /spec/coffee_order_spec.rb
RSpec.describe CoffeeOrder do
  let(:order) { CoffeeOrder.new('Latte', 'medium') }

  it "returns the same object each time in an example" do
    expect(order).to equal(order) # true: memoized!
  end
end
```

Notice: No `@calculator`! The `let(:calculator)` line creates a method called `calculator` you can use in your tests. The value is only created once per example.

## let!: Eager Evaluation (and a Caution)

Sometimes you want your setup code to run before each example, no matter what. That’s what `let!` is for. **Warning:** If you use `let!` to set up heavy or slow objects (like database records), it can slow down your test suite—only use it when you really need eager setup.

```ruby
# /spec/coffee_order_spec.rb
RSpec.describe CoffeeOrder do
  let!(:order) { CoffeeOrder.new('Latte', 'medium') }

  it "returns the drink name" do
    expect(order.drink).to eq('Latte')
  end
end
```

Here, `let!` ensures the user is created before each test, even if you don’t reference `user` in the example.

## let vs let!: What’s the Difference?

- `let` is lazy: it only runs if you use it in the test.
- `let!` is eager: it always runs before each test.

Try this experiment:

```ruby
# /spec/experiment_spec.rb
RSpec.describe "let vs let!" do
  let(:lazy) { puts "let runs!" }
  let!(:eager) { puts "let! runs!" }

  it "shows when let and let! run" do
    # Only let! runs so far
    lazy # Now let runs
  end
end
```

Check your test output to see when each message appears!

## Why Use let/let! Over before/instance variables?

- `let` keeps your specs DRY and focused—no more unused instance variables.
- It’s easier to see what data each test uses.
- You can override `let` in nested contexts for even more flexibility.

## When NOT to Use let/let

While `let` and `let!` are the best choice for most test data, there are a few situations where you might want to use something else. Here’s when you should consider a different approach:

- **You need to set up something once for all tests in a group (and it’s expensive):**

  - Use `before(:all)` and an instance variable if you’re, for example, connecting to a database or starting a server that should only be set up once. (But be careful: instance variables set in `before(:all)` are shared across tests, so don’t modify them in your examples!)
  - Example:

    ```ruby
    # /spec/database_spec.rb
    RSpec.describe Database do
      before(:all) do
        @db = Database.connect # Only runs once for all examples
      end

      it "can find a user" do
        expect(@db.find_user("alice")).not_to be_nil
      end
    end
    ```

- **You need to share state between examples:**

  - This is rare and usually a code smell, but sometimes you want to accumulate data across tests. In that case, use a class variable or a shared object, not `let`.
- **You want to set up something outside of an example (like in a helper method or outside a spec block):**

  - `let` only works inside specs. For shared helpers, use regular Ruby methods or modules.
- **You need to mutate the value in multiple tests:**

  - `let` values are memoized (cached) per example and reset for each test. If you need to change a value and have it persist across tests, use an instance variable with `before(:all)` (but again, be careful!).

In summary: use `let` and `let!` for most test data, but reach for `before(:all)` and instance variables for expensive, one-time setup, or when you truly need shared state. When in doubt, prefer `let`—it’s almost always the right choice!

## Getting Hands-On

Ready to practice? Here’s how to get started:

1. **Fork and clone this repo to your own GitHub account.**
2. **Install dependencies:**

    ```zsh
    bundle install
    ```

3. **Run the specs:**

    ```zsh
    bin/rspec
    ```

4. **Explore the code:**

   - All lesson code uses the CoffeeOrder and Cafe domain (see `lib/` and `spec/let_spec.rb`).
   - Review the examples for using `let` and `let!` in different ways.

5. **Implement the pending specs:**

   - Open `spec/let_spec.rb` and look for specs marked as `pending`.
   - Implement the real methods in `lib/coffee_order.rb` or `lib/cafe.rb` as needed so the pending specs pass.

6. **Re-run the specs** to verify your changes!

**Challenge:** Try writing your own spec using `let` or `let!` for a new method on CoffeeOrder or Cafe.

---

## Resources

- [RSpec let and let! Documentation](https://relishapp.com/rspec/rspec-core/v/3-10/docs/helper-methods/let-and-let)
- [Better Specs: let](https://www.betterspecs.org/#let)
- [Ruby Guides: RSpec let](https://www.rubyguides.com/2018/07/rspec/)

*Next: You’ll learn how to add custom error messages and helper methods to make your specs even more readable!*
