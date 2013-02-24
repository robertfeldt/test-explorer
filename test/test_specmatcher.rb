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
    it "extracts the right subgen names when there is only one subgen specified" do
      sm = SpecMatcher.new(/an array of _X_s/)
      sm.subgen_names.must_equal ["X"]
      sm.regexp.must_equal /an array of (.+)s/
    end

    it "extracts the right subgen names when there are two subgen's specified" do
      sm = SpecMatcher.new(/a hash mapping _X_s to _Y_s/)
      sm.subgen_names.sort.must_equal ["X", "Y"].sort
      sm.regexp.must_equal /a hash mapping (.+)s to (.+)s/
    end

    it "matches when there is a simple subgen in the spec" do
      sm = SpecMatcher.new(/an array of _X_s/)
      res = sm.match("an array of integers")

      # Make sure there is a match, i.e. not returning false or nil
      res.wont_equal false
      res.wont_equal nil

      # Rather we get back a GenConstraints object
      res.must_be_instance_of TestExplorer::GenConstraints
      res["X"].must_equal "integer"
      res[:X].must_equal "integer"
    end
  end
end