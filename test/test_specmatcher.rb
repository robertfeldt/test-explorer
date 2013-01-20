describe "Spec matcher" do
  it "matches a valid generator spec" do
    sm = SpecMatcher.new(/an array/)
    sm.match("an array").must_equal true
  end

  it "does not match if it does not match the full spec given" do
    sm = SpecMatcher.new(/an array/)
    sm.match("an array of integers").must_equal false
  end

  describe "Matchers with subgen variables in them" do
    if "matches when there is a simple subgen in the spec" do
      sm = SpecMatcher.new(/an array of _X_s/)
      res = sm.match("an array of integers")
      # Make sure there is a match, i.e. not returning false or nil
      res.wont_equal false
      res.wont_equal nil
      # Rather we get back a GenConstraints object
      res.must_be_instance_of TestExplorer::MagicGen::GenConstraints
      res[:X].must_equal "integer"
    end
  end
end