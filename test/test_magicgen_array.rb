include CoreGenerators

describe "Array gen" do
  it "can describe itself" do
    descs = ArrayGen.descriptions
    descs.must_be_instance_of Array
    descs.each {|elem| elem.must_be_instance_of String}
  end

  it "matches a valid generator spec with no size given" do
    ArrayGen.can_generate?("an array").must_equal true
  end

  it "matches a valid generator spec with size given" do
    ArrayGen.can_generate?("an array of integers").must_equal true
  end
end