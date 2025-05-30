extend Math
include Math

def π
  PI
end

def √(x)
  sqrt(x)
end


# https://en.wikipedia.org/wiki/Sigmoid_function
def sigmoid(x)
  1.0 / (1.0 + exp(-x))
end

# https://en.wikipedia.org/wiki/Softmax_function
def softmax(arr)
  vec = arr.map{|x| exp(x) }
  sum = vec.sum
  vec.map{|x| x / sum }
end

# https://en.wikipedia.org/wiki/B%C3%A9zier_curve
def cubic_bezier(t, p0, p1, p2, p3)
  (1-t)**3 * p0 \
  + 3*(1-t)**2 * t * p1 \
  + 3*(1-t) * t**2 * p2 \
  + t**3 * p3
end
