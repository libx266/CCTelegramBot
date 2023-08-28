function relu(x)
    local result = math.max(0, x)
    return math.floor(result + 0.5)
  end