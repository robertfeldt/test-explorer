module TestExplorer::CoreGenerators

class ArrayGen < TestExplorer::MagicGen
  describe "generates Array's of values of differing sizes"
  generates /an array/
  generates /an array of _X_s/
  generates /an array of _X_s of size (\d+)/, [:size]
  generates /an array of _X_s of length (\d+)/, [:size]
  def gen(constraints)
    Array.new(constraints.getme(:size)) {constraints.getme(:X)}
  end
end

end