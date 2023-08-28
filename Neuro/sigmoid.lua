function sigmoid(x)
  local sigmoid_range = 15
  local input_range = 15

  local scaled_x = (2 * sigmoid_range * x / input_range) - sigmoid_range
  local result = sigmoid_range / (1 + math.exp(-scaled_x))
  
  return math.floor(result + 0.5)
end