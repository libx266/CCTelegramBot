function tanh(x)
    local scaled_x = (2 * x / 15) - 1
    local result = math.tanh(scaled_x)
    
    result = (result + 1) * 7.5
    return math.floor(result + 0.5)
  end