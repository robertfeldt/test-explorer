require 'test-explorer/test_executor'

# Example SUT
class Stack
  def initialize(ary = [])
    @elements = ary
  end
  def push(o)
    @elements.push o
  end
  def size
    @elements.length
  end
  def pop
    @elements.pop
  end
  def clear
    @elements.clear
  end
  def peek
    @elements.last
  end
end

describe "TestCaseExecutor" do
  describe "ExecutionContext" do
    it "properly extracts methods from the SUT and can map to them based on numbers" do
      ec = TestCaseExecutor::ExecutionContext.new(Stack)
      ec.method(0).must_equal :push
      ec.method(1).must_equal :size
      ec.method(2).must_equal :pop
      ec.method(3).must_equal :clear
      ec.method(4).must_equal :peek
    end
  end
end