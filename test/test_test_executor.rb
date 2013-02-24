require 'test-explorer/test_executor'

# Example SUT 1
class Stack
  def initialize(ary = [])
    @elements = ary
  end
  def push(o)
    @elements.push o
    self
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

# Example SUT 2
class RaisesExceptions
  def not_implemented(raiseException = false)
    raise NotImplementedError if raiseException
  end
end


describe "TestCaseExecutor" do
  describe "ExecutionContext" do
    it "saves the SUT" do
      ec = TestCaseExecutor::ExecutionContext.new(Stack)
      ec.sut.must_equal Stack
    end

    it "properly extracts methods from the SUT and can map to them based on numbers" do
      ec = TestCaseExecutor::ExecutionContext.new(Stack)
      ec.method(0).must_equal :push
      ec.method(1).must_equal :size
      ec.method(2).must_equal :pop
      ec.method(3).must_equal :clear
      ec.method(4).must_equal :peek
    end

    it "creates OUT from SUT when has not been done with explicit calls" do
      ec = TestCaseExecutor::ExecutionContext.new(Stack)
      ec.object.must_be_instance_of Stack
    end

    it "can extract args from stack when stack is larger than or equal in size to the number of requested args" do
      ec = TestCaseExecutor::ExecutionContext.new(Stack)
      ec.stack_push 1
      ec.stack_push 2
      ec.stack_push 3
      ec.extract_args(1).must_equal [3]
      ec.extract_args(2).must_equal [1,2]
    end

    it "can extract args from stack when stack is smaller than requested number of args" do    
      ec = TestCaseExecutor::ExecutionContext.new(Stack)
      ec.stack_push 1
      ec.stack_push 2
      ec.stack_size.must_equal 2
      ec.extract_args(3).must_equal [nil, 1, 2]
      ec.stack_size.must_equal 0
    end

    it "creates OUT from SUT when a method is called without an explicit call to create object has been done" do
      ec = TestCaseExecutor::ExecutionContext.new(Stack)
      ec.stack_push 2
      call_info = ec.call_method_on_object(0, 1)
      call_info.object.must_be_instance_of Stack
    end

    it "creates the proper CallInfo object when one method is called" do
      ec = TestCaseExecutor::ExecutionContext.new(Stack)
      ec.stack_push 2
      call_info = ec.call_method_on_object(0, 1)
      call_info.object.must_be_instance_of Stack
      call_info.method.must_equal :push
      call_info.args.must_equal [2]
      call_info.return.must_be_instance_of TestCaseExecutor::ExecutionContext::NormalReturn
      # The call to push returns the stack itself:
      call_info.return.result.must_be_instance_of Stack
      call_info.return.result.size.must_equal 1
      call_info.return.result.pop.must_equal 2
    end

    it "creates the proper CallInfo object when two methods are called" do
      ec = TestCaseExecutor::ExecutionContext.new(Stack)
      ec.stack_push 2
      call_info1 = ec.call_method_on_object(0, 1) # Corresponds to stack.push(2)
      call_info2 = ec.call_method_on_object(2, 0) # Corresponds to stack.pop

      call_info2.object.must_be_instance_of Stack
      call_info2.method.must_equal :pop
      call_info2.args.must_equal []
      call_info2.return.must_be_instance_of TestCaseExecutor::ExecutionContext::NormalReturn
      call_info2.return.result.must_equal 2
    end

    it "creates the proper CallInfo object when three methods are called" do
      ec = TestCaseExecutor::ExecutionContext.new(Stack)
      ec.stack_push 2
      call_info1 = ec.call_method_on_object(0, 1) # Corresponds to stack.push(2)
      call_info2 = ec.call_method_on_object(2, 0) # Corresponds to stack.pop
      call_info3 = ec.call_method_on_object(1, 0) # Corresponds to stack.size

      call_info3.object.must_be_instance_of Stack
      call_info3.method.must_equal :size
      call_info3.args.must_equal []
      call_info3.return.must_be_instance_of TestCaseExecutor::ExecutionContext::NormalReturn
      call_info3.return.result.must_equal 0
    end

    it "creates the proper CallInfo when calling a method that raises and exception" do
      ec = TestCaseExecutor::ExecutionContext.new(RaisesExceptions)

      ec.stack_push false
      call_info = ec.call_method_on_object(0, 1) # Corresponds to re.not_implemented(false) => nil

      call_info.object.must_be_instance_of RaisesExceptions
      call_info.method.must_equal :not_implemented
      call_info.args.must_equal [false]
      call_info.return.must_be_instance_of TestCaseExecutor::ExecutionContext::NormalReturn
      call_info.return.result.must_equal nil

      ec.stack_push true
      call_info = ec.call_method_on_object(0, 1) # Corresponds to re.not_implemented(true) => raises exception

      call_info.object.must_be_instance_of RaisesExceptions
      call_info.method.must_equal :not_implemented
      call_info.args.must_equal [true]
      call_info.return.must_be_instance_of TestCaseExecutor::ExecutionContext::ExceptionReturn
      call_info.return.result.must_be_instance_of NotImplementedError
    end
  end
end