module TestExplorer::CoreGenerators

class ArrayGen < TestExplorer::MagicGen
  describe "generates Array's of values of differing sizes"
  generates /an array/
  generates /an array of _X_s/
  generates /an array of _X_s of (size|length) (?<size>\d+)/
  def gen()
    Array.new(constraints.gen(:size)) {constraints.gen(:X)}
  end
end

end