# RSpec: let and let!: Lazy, Powerful, and a Little Mysterious

Welcome to Lesson 7! If you’ve ever wondered, “Is there a better way to set up test data than using instance variables everywhere?”—let us introduce you to `let` and `let!`. These RSpec helpers are like the secret agents of your test suite: they show up only when you need them, keep your specs clean, and sometimes even surprise you with their cleverness. Let’s break down what they do, how they work, and why you’ll love them (with lots of examples and clarifications, of course).

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
# /spec/calculator_spec.rb
RSpec.describe Calculator do
  before(:each) do
    @calculator = Calculator.new
  end

  it "adds numbers" do
    expect(@calculator.add(2, 3)).to eq(5)
  end

  it "subtracts numbers" do
    expect(@calculator.subtract(5, 2)).to eq(3)
  end
end
```

#### Using *let* (the modern way)

```ruby
# /spec/calculator_spec.rb
RSpec.describe Calculator do
  let(:calculator) { Calculator.new }

  it "adds numbers" do
    expect(calculator.add(2, 3)).to eq(5)
  end

  it "subtracts numbers" do
    expect(calculator.subtract(5, 2)).to eq(3)
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
# /spec/calculator_spec.rb
RSpec.describe Calculator do
  let(:calculator) { Calculator.new }

  context "with default calculator" do
    it "adds numbers" do
      expect(calculator.add(1, 2)).to eq(3)
    end
  end

  context "with a special calculator" do
    let(:calculator) { SpecialCalculator.new }

    it "adds numbers differently" do
      expect(calculator.add(1, 2)).to eq(42) # SpecialCalculator is weird!
    end
  end
end
```

Try doing that with instance variables—it gets messy fast!

**How does RSpec resolve which let to use?**

```ruby
RSpec.describe "let resolution" do
  let(:thing) { "outer" }
  context "outer context" do
    # thing == "outer"
    context "inner context" do
      let(:thing) { "inner" }
      # thing == "inner" (overrides outer)
    end
  end
end
```

Resolution order: RSpec looks for the closest let in the current context, then moves outward until it finds one.

## let: Lazy Evaluation and Memoization in Action

With `let`, the value isn’t created until you actually use it in your test. This can make your specs faster and easier to understand. **Bonus:** The value is memoized—multiple calls to the same `let` in a single example return the same object.

```ruby
# /spec/calculator_spec.rb
RSpec.describe Calculator do
  let(:calculator) { Calculator.new }

  it "returns the same object each time in an example" do
    expect(calculator).to equal(calculator) # true: memoized!
  end
end
```

Notice: No `@calculator`! The `let(:calculator)` line creates a method called `calculator` you can use in your tests. The value is only created once per example.

## let!: Eager Evaluation (and a Caution)

Sometimes you want your setup code to run before each example, no matter what. That’s what `let!` is for. **Warning:** If you use `let!` to set up heavy or slow objects (like database records), it can slow down your test suite—only use it when you really need eager setup.

```ruby
# /spec/user_spec.rb
RSpec.describe User do
  let!(:user) { User.create(name: "Alice") }

  it "finds the user by name" do
    expect(User.find_by(name: "Alice")).to eq(user)
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

## Practice Prompts

1. Refactor a spec that uses `before` and instance variables to use `let` instead. What changes?
2. Try using `let!` to set up a database record. What happens if you don’t reference it in your test?
3. Write a spec with nested contexts that override a `let` value. How does RSpec decide which value to use?
4. Why is lazy evaluation useful in testing? Write your answer in your own words.

---

## Resources

- [RSpec let and let! Documentation](https://relishapp.com/rspec/rspec-core/v/3-10/docs/helper-methods/let-and-let)
- [Better Specs: let](https://www.betterspecs.org/#let)
- [Ruby Guides: RSpec let](https://www.rubyguides.com/2018/07/rspec/)

*Next: You’ll learn how to add custom error messages and helper methods to make your specs even more readable!*
