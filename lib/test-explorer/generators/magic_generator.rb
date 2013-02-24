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

  def initialize(constraints = TestExplorer::GenConstraints.new)
    @constraints = constraints
  end
end

# A GenConstraints object holds constraints on sub generators, size/length values
# etc. and can generate objects for them to support a generator.
class GenConstraints
  def initialize
  end
end

# A SpecMatcher is a regexp that is used to match generator specifications
# and extract any constraints on sub-generators, sizes and so forth
# to be used in the generation.
class SpecMatcher
  attr_reader :subgen_names, :regexp

  def initialize(regexp, partNames = [])
    #@orig_regexp = regexp
    @part_names = partNames
    @regexp, @subgen_map = extract_subgen_map_and_construct_new_regexp_with_wildcards(regexp)
  end

  # Match a generator request to this matcher. Returns a GenConstraints object
  # if there is a match, nil otherwise.
  def match(generatorSpec)
    matchdata = @regexp.match(generatorSpec)
    if (matchdata != nil)
      # Put together the subgen and
      matchdata.matches.each
      GenConstraints.new()
    else
      nil
    end
  end

  private

  # Regexp matching sub generators in a spec matcher regexp.
  SubGenRegExp = /_([A-Z]+[0-9A-Z]*)_s?/

  # Find the names of all subgens used in a spec match regexp and substitute
  # /(.+)/ for each one of them.
  def extract_subgen_map_and_construct_new_regexp_with_wildcards(regexp)
    new_regexp_str, @subgen_map = regexp.source.clone, Hash.new {|h,k| h[k] ||= Array.new}
    subgen_index = 1
    regexp.source.scan(SubGenRegExp) do |match|
      subgen_name = match.first
      new_regexp_str = new_regexp_str.gsub("_#{subgen_name}_", "(?<SUBGEN#{subgen_index}>.+)")
      @subgen_map[subgen_name] << subgen_index
      subgen_index += 1
    end
    return Regexp.new(new_regexp_str), @subgen_map
  end
end

# All Generators supplied with test-explorer are in the CoreGenerators
# module. All user ones will live under UserGenerators.
module CoreGenerators; end
module UserGenerators; end

end