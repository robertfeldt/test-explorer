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

  # Generate using this generator and a given generator spec.
  # We assume we already can generate data for the given spec, i.e.
  # that the caller has ensured this by calling can_generate? before calling
  # this method.
  def self.generate(generatorSpec)
    constraints = constraints_matching(generatorSpec)
    self.new(constraints).gen()
  end

  def self.constraints_matching(generatorSpec)
    spec_matchers.each do |sm|
      m = sm.match(generatorSpec)
      return m if m
    end
  end

  attr_reader :constraints

  def initialize(constraints = TestExplorer::GenConstraints.new)
    @constraints = constraints
  end
end

# A GenConstraints object holds constraints on sub generators, size/length values
# etc. and can generate objects for them to support a generator.
class GenConstraints
  def initialize(matchdata, matcher)
    @matchdata, @matcher = matchdata, matcher
  end

  def [](name)
    @matchdata[@matcher.capture_name_for_subgen_named(name)]
  end

  def gen(name)
    return 3 if name == :size
    return 2 if name == :X
  end
end

# A SpecMatcher is a regexp that is used to match generator specifications
# and extract any constraints on sub-generators, sizes and so forth
# to be used in the generation.
class SpecMatcher
  attr_reader :regexp, :subgen_names

  def initialize(regexp, partNames = [])
    @orig_regexp = regexp
    @part_names = partNames
    @regexp, @subgen_names = extract_subgen_map_and_construct_new_regexp_with_wildcards(regexp)
  end

  # Match a generator request to this matcher. Returns a GenConstraints object
  # if there is a match, nil otherwise.
  def match(generatorSpec)
    matchdata = @regexp.match(generatorSpec)
    if (matchdata != nil)
      GenConstraints.new(matchdata, self)
    else
      false
    end
  end

  def capture_name_for_subgen_named(subgenName)
    "SUBGEN_" + subgenName.to_s
  end

  private

  # Regexp matching sub generators in a spec matcher regexp.
  SubGenRegExp = /_([A-Z]+[0-9A-Z]*)_s?/

  # Find the names of all subgens used in a spec match regexp and substitute
  # /(.+)/ for each one of them.
  def extract_subgen_map_and_construct_new_regexp_with_wildcards(regexp)
    new_regexp_str, subgen_names = "^" + regexp.source.clone + "$", []
    regexp.source.scan(SubGenRegExp) do |match|
      subgen_names << (subgen_name = match.first)
      new_regexp_str = new_regexp_str.gsub("_#{subgen_name}_", "(?<#{capture_name_for_subgen_named(subgen_name)}>.+)")

    end
    return Regexp.new(new_regexp_str), subgen_names
  end
end

# All Generators supplied with test-explorer are in the CoreGenerators
# module. All user ones will live under UserGenerators.
module CoreGenerators; end
module UserGenerators; end

end