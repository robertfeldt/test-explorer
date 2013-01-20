module TestExplorer

# A MagicGen can take strings describing what kind of object a user wants
# and return such an object.
class MagicGen
  def self.describe description
    descriptions << description
  end

  def self.descriptions
    @descriptions ||= []
  end

  # A user can add Regexp's to match generator specs that this Gen can fulfill.
  def self.generates specMatcher, partNames = []
    spec_matchers << SpecMatcher.new(specMatcher, partNames)
  end

  # The list of generator spec matchers this generator currently has.
  def self.spec_matchers
    @spec_matchers ||= []
  end

  # Check if the given generator specification can be generated.
  def self.can_generate?(generatorSpec)
    spec_matchers.any? {|sm| sm.match(generatorSpec)}
  end

  # Generate using this generator.
  def self.gen(constraints = nil)
    # Instantiate with the constraints and then generate.
    self.new(constraints).gen
  end

  def initialize(constraints = TestExplorer::MagicGen::Constraints.new)
    @constraints = constraints
  end
end

# A SpecMatcher is a regexp that is used to match generator specifications
# and extract any constraints on sub-generators, sizes and so forth
# to be used in the generation.
class SpecMatcher
  def initialize(regexp, partNames = [])
    @re = regexp
    @part_names = partNames
  end

  # Match a generator spec.
  def match(generatorSpec)
    matchdata = @re.match(generatorSpec)
    (matchdata != nil) && (matchdata[0] == generatorSpec)
  end
end

# All Generators supplied with test-explorer are in the CoreGenerators
# module. All user ones will live under UserGenerators.
module CoreGenerators; end
module UserGenerators; end

end