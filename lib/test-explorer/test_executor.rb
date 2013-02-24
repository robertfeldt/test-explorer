class Object
  def deep_clone
    Marshal.load( Marshal.dump(self) )
  end
end

module TestExplorer

def self.map_methods_to_numbers(klass, startNum = 0)
  methods = klass.instance_methods - klass.ancestors[1].instance_methods
  map = Hash.new
  num_range = startNum..(startNum+methods.length)
  methods.zip(num_range).each {|m,n| map[m] = n}
  map
end

class TestCaseExecutor
  # Context for one specific execution of a test case.
  class ExecutionContext
    attr_reader :sut

    def initialize(sut, startStack = [])
      @sut, @stack, @log = sut, startStack, []
      @methods = TestExplorer.map_methods_to_numbers(sut).invert
      @num_methods = @methods.length
    end

    def stack_push(o)
      @stack.push o
    end

    def stack_size
      @stack.length
    end

    # Return the _num_ method of the OUT, assuming it is an instance of the
    # SUT being tested.
    def method(num)
      @methods[num % @num_methods]
    end

    CallInfo = Struct.new(:object, :method, :args, :return)
    NormalReturn = Struct.new(:result)
    ExceptionReturn = Struct.new(:result)

    def call_method_on_object(methodNum, numArgs)
      args = extract_args(numArgs)
      method = method(methodNum)
      # We clone them before the call since they might be affected in the call
      object_clone = object.deep_clone
      args_clone = args.deep_clone
      begin
        res = object.send(method, *args)
        # Also deep clone the result since the object might keep pointers to it and change it later. We can't be sure.
        result = NormalReturn.new(res.deep_clone)
      rescue Exception => e
        result = ExceptionReturn.new(e)
      end
      ci = CallInfo.new object_clone, method, args_clone, result
      log_action ci
    end

    def extract_args(numArgs)
      if numArgs > stack_size
        args = @stack
        @stack = []
        array_of_nils_to_pad_with = Array.new(numArgs - args.length)
        array_of_nils_to_pad_with + args
      else  
        args = @stack[@stack.length - numArgs, numArgs]
        @stack = @stack[0, @stack.length - args.length]
        args
      end
    end

    def object
      @object ||= create_object()
    end

    # Default way to create an object is to call it without parameters. If parameters are needed
    # this must be done explicitly by calls from the test case.
    def create_object
      sut.send(:new)
    end

    def log_action(action)
      @log << action
      action
    end
  end

  # An instruction to be executed by this executor.
  class Instruction
    def run(context, program)
    end
  end

  class Push < Instruction
    def run(context, program)
      context.stack_push program.first
      program.drop(1)
    end
  end

  class Call0 < Instruction
    def run(context, program)
      context.call_method_on_object(program.first, num_args())
      program.drop(1)
    end
    def num_args; 0; end
  end

  class Call1 < Call0
    def num_args; 1; end
  end

  class Call2 < Call0
    def num_args; 2; end
  end

  DefaultInstructionMap = {
    0 => Push,
    0 => Call0,
    1 => Call1,
    2 => Call2,
  }

  def initialize(sut, instructionMap = DefaultInstructionMap)
    @instruction_map, @sut = instructionMap, sut
  end

  # Execute an individual, i.e. an array of
  def execute(individual, sut = nil, instructionMap = nil)
    instruction_map = instructionMap || @instruction_map
    sut ||= @sut
    stack = ExecutionStack.new # Get a new, clear stack for this execution. This also allows thread-safe calls to this execute method for parallellization.
    program = individual.clone
    while program.length > 0
      instruction = get_next_instruction(program)
      program = program.drop(1) # Drop the instruction we just popped
      program = instruction.run(self, program)
    end
  end
end

end