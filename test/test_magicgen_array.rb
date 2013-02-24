include CoreGenerators

describe "Array gen" do
  it "can describe itself" do
    descs = ArrayGen.descriptions
    descs.must_be_instance_of Array
    descs.each {|elem| elem.must_be_instance_of String}
  end

  it "matches a valid generator spec with no size or subgen type given" do
    ArrayGen.can_generate?("an array").must_equal true
  end

  it "matches a valid generator spec with type for subgen given" do
    ArrayGen.can_generate?("an array of integers").must_equal true
  end

  it "matches a valid generator spec with type for subgen and size given" do
    ArrayGen.can_generate?("an array of integers of size 3").must_equal true
  end

  it "matches a valid generator spec with type for subgen and length given" do
    ArrayGen.can_generate?("an array of integers of length 10").must_equal true
  end

  it "can generate arrays of integers" do
    data = ArrayGen.generate("an array of integers")
    data.must_be_instance_of Array
    data.each {|v| v.must_be_instance_of Fixnum}
  end
end