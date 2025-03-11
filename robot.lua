---@diagnostic disable: lowercase-global
-- coordinate system:
-- x: forward (+) and backward (-)
-- y: up (+) and down (-)
-- z: left (-) and right (+)

reverse = {
  ['forward'] = 'backward',
  ['backward'] = 'forward',
  ['left'] = 'right',
  ['right'] = 'left',
  ['up'] = 'down',
  ['down'] = 'up'
}

-- direction can be forward, backward, left, right
Direction = 'forward'

VeinBlock = ''

Position = 0

function Set(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

NotOreBlock = Set {
  'minecraft:stone',
  'minecraft:dirt',
  'minecraft:gravel',
  'minecraft:sand',
  'minecraft:andesite',
  'minecraft:diorite',
  'minecraft:granite',
  'minecraft:deepslate',
  'minecraft:grass'
}

function isOreBlock(name)
  return not NotOreBlock[name]
end

function leftOf(direction)
  if direction == 'forward' then
    return 'left'
  elseif direction == 'left' then
    return 'backward'
  elseif direction == 'backward' then
    return 'right'
  else
    return 'forward'
  end
end

function inspect()
  local directions = {}

  local d = Direction

  for _ = 0, 3 do
    local b, data = turtle.inspect()
    if b and data.name == VeinBlock then
      table.insert(directions, d)
    end
    turtle.turnLeft()
    d = leftOf(d)
  end

  b, data = turtle.inspectUp()
  if b and data.name == VeinBlock then
    table.insert(directions, 'up')
  end

  b, data = turtle.inspectDown()
  if b and data.name == VeinBlock then
    table.insert(directions, 'down')
  end

  return directions
end

function inspectDir(direction)
  if direction == 'up' then
    return turtle.inspectUp()
  elseif direction == 'down' then
    return turtle.inspectDown()
  else
    face(direction)
    return turtle.inspect()
  end
end

function face(direction) -- direction can be forward, backward, left, right
  if direction == 'forward' then
    if Direction == 'left' then
      turtle.turnRight()
    elseif Direction == 'right' then
      turtle.turnLeft()
    elseif Direction == 'backward' then
      turtle.turnLeft()
      turtle.turnLeft()
    end
  elseif direction == 'backward' then
    if Direction == 'left' then
      turtle.turnLeft()
    elseif Direction == 'right' then
      turtle.turnRight()
    elseif Direction == 'forward' then
      turtle.turnLeft()
      turtle.turnLeft()
    end
  elseif direction == 'left' then
    if Direction == 'forward' then
      turtle.turnLeft()
    elseif Direction == 'right' then
      turtle.turnLeft()
      turtle.turnLeft()
    elseif Direction == 'backward' then
      turtle.turnRight()
    end
  else
    if Direction == 'forward' then
      turtle.turnRight()
    elseif Direction == 'left' then
      turtle.turnLeft()
      turtle.turnLeft()
    elseif Direction == 'backward' then
      turtle.turnLeft()
    end
  end
  Direction = direction
end

function move(direction) -- direction can be forward, backward, left, right, up, down
  if direction == 'up' then
    turtle.up()
  elseif direction == 'down' then
    turtle.down()
  else
    face(direction)
    turtle.forward()
  end
end

function mine(direction) -- direction can be forward, backward, left, right, up, down
  if direction == 'up' then
    turtle.digUp()
  elseif direction == 'down' then
    turtle.digDown()
  else
    face(direction)
    turtle.dig()
  end
end

VeinBlock = ''

function mineVein(direction)
  has_block, data = inspectDir(direction)
  if not has_block or data.name ~= VeinBlock then
    return
  end
  mine(direction)
  move(direction)

  local nextDirections = inspect()


  for _, dir in pairs(nextDirections) do
    mineVein(dir)
  end

  move(reverse[direction])
end

function mineVertically()
  while true do
    Position = Position + 1
    mine('down')
    move('down')
    hasDown, downData = inspectDir('down')

    -- go to top when reaching bedrock
    if hasDown then
      if downData.name == 'minecraft:bedrock' then
        break
      end

      if isOreBlock(downData.name) then
        VeinBlock = downData.name
        mineVein('down')
        VeinBlock = ''
      end
    end

    hasForward, forwardData = inspectDir('forward')
    if hasForward and isOreBlock(forwardData.name) then
      VeinBlock = forwardData.name
      mineVein('forward')
      VeinBlock = ''
    end

    hasLeft, leftData = inspectDir('left')

    if hasLeft and isOreBlock(leftData.name) then
      VeinBlock = leftData.name
      mineVein('left')
      VeinBlock = ''
    end

    hasBackward, backwardData = inspectDir('backward')

    if hasBackward and isOreBlock(backwardData.name) then
      VeinBlock = backwardData.name
      mineVein('backward')
      VeinBlock = ''
    end

    hasRight, rightData = inspectDir('right')

    if hasRight and isOreBlock(rightData.name) then
      VeinBlock = rightData.name
      mineVein('right')
      VeinBlock = ''
    end
  end

  for i = 1, Position, 1 do
    move('up')
  end

  Position = 0
  if turtle.detect() then turtle.dig() end
  move('forward')
  if turtle.detect() then turtle.dig() end
  move('forward')

  mineVertically()
end

mineVertically()
