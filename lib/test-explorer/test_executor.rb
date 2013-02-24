module TestExplorer

def self.map_methods_to_numbers(klass, startNum = 0)
  methods = klass.instance_methods - klass.ancestors[1].instance_methods
  map = Hash.new
  num_range = startNum..(startNum+methods.length)
  methods.zip(num_range).each {|m,n| map[m] = n}
  map
end

class TestCaseExecutor
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

    # Return the _num_ method of the OUT, assuming it is an instance of the
    # SUT being tested.
    def method(num)
      @methods[num % @num_methods]
    end

    def call_method_on_object(methodNum, numArgs)
      args = extract_args(numArgs)
      method = method_name(methodNum)
      ci = CallInfo.new object.deep_clone, method, args.deep_clone
      begin
        result = NormalReturn.new(object.send(method, args))
      rescue Exception => e
        result = ExceptionReturn.new(e)
      end
      ci.add_result result
      log_action ci
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