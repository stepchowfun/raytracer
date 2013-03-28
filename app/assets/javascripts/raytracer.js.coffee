# represents a point
class window.Point
  # constructor
  constructor: (@x, @y, @z) ->

  # get the length squared
  len_sq: () -> @x * @x + @y * @y + @z * @z

  # get the length
  len: () -> Math.sqrt(@x * @x + @y * @y + @z * @z)

  # return the sum of this and another point
  add: (other) ->
    return new Point(@x + other.x, @y + other.y, @z + other.z)

  # return the difference of this and another point
  subtract: (other) ->
    return new Point(@x - other.x, @y - other.y, @z - other.z)

  # return the dot product of this and another point
  dot: (other) ->
    return @x * other.x + @y * other.y + @z * other.z

  # return the cross product of this and another point
  cross: (other) ->
    return new Point(@y * other.z - @z * other.y, @z * other.x - @x * other.z, @x * other.y - @y * other.z)

  # normalize the vector
  scaled: (s) ->
    return new Point(@x * s, @y * s, @z * s)

  # normalize the vector
  normalized: () ->
    len_inv = 1 / @len()
    return new Point(@x * len_inv, @y * len_inv, @z * len_inv)

# represents a ray
class window.Ray
  # constructor
  constructor: (@origin, @dir) ->

# represents a color
class window.Color
  # constructor (component values must lie in range [0, 1])
  constructor: (@r, @g, @b) ->

  # returns a CSS-compatible string
  to_str: () -> "rgb(" + String(Math.round(@r * 255)) + ", " + String(Math.round(@g * 255)) + ", " + String(Math.round(@b * 255)) + ")";

# represents the result of an intersection
class window.Hit
  # constructor
  constructor: (@t, @color) ->

# represents an object in the scene
class window.Sphere
  # constructor
  constructor: (@pos, @radius, @color) ->

  # intersect the object with a ray, returns a Hit object or null
  intersect: (ray) ->
    discriminant = Math.pow(ray.dir.dot(ray.origin.subtract(@pos)), 2) - ray.origin.subtract(@pos).len_sq() + Math.pow(@radius, 2)
    if discriminant < 0
      return null
    t1 = -ray.dir.dot(ray.origin.subtract(@pos)) - Math.sqrt(discriminant)
    t2 = -ray.dir.dot(ray.origin.subtract(@pos)) + Math.sqrt(discriminant)
    if t2 <= 0
      return null
    if t1 > 0
      t = t1
    else
      t = t2
    color_factor = Math.pow(Math.sin((ray.origin.y + ray.dir.y * t) / 3), 2)
    return new Hit(t, new Color(@color.r * color_factor, @color.g * color_factor, @color.b * color_factor))

# represents an plane in the scene
class window.Plane
  # constructor
  constructor: (@pos, @normal, @color) ->

  # intersect the object with a ray, returns a Hit object or null
  intersect: (ray) ->
    denom = ray.dir.dot(@normal)
    if denom == 0
      return null
    t = @pos.subtract(ray.origin).dot(@normal) / denom
    if t <= 0
      return null

    p = ray.origin.add(ray.dir.scaled(t))
    color = if Math.sin(p.x) + Math.sin(p.y) > 0 then new Color(0.1, 0.1, 0.1) else new Color(0.2, 0.2, 0.2)

    return new Hit(t, color)

# a list of objects in the scene
window.scene_graph = []

# background color
window.background_color = new Color(0, 0, 0)

# device information
window.render_context = null
window.render_x = 0
window.render_y = 0
window.render_width = 100
window.render_height = 100

# the camera
window.camera = {
  # the location of the camera in world-space
  pos: new Point(0, 0, 0),

  # a unit vector describing the forward direction of the camera
  aim: new Point(1, 0, 0),

  # a unit vector describing the left direction of the camera
  left: new Point(0, 1, 0),

  # a unit vector describing the up direction of the camera
  up: new Point(0, 0, 1),

  # horizontal field of view in radians
  fov: 1.0471975512,

  # aspect ratio (width/height)
  aspect: 1
}

# sample the color at a point in screen space
sample = (x, y) ->
  # compute which ray corresponds to this point
  left = -(x / window.render_width - 0.5) * 2.0 * Math.tan(window.camera.fov * 0.5)
  up = -(y / window.render_height - 0.5) * 2.0 * Math.tan(window.camera.fov * 0.5) / window.camera.aspect
  dir = window.camera.aim.add(window.camera.left.scaled(left)).add(window.camera.up.scaled(up)).normalized()
  ray = new Ray(window.camera.pos, dir)

  # intersect the ray with all the objects in the scene graph
  t = null
  col = window.background_color
  for i in [0...window.scene_graph.length]
    hit = window.scene_graph[i].intersect(ray)
    if hit != null and (t == null or hit.t < t)
      t = hit.t
      col = hit.color

  # return the color
  return col

# render a piece of the scene
render_block = (x, y, width, height, samples, dev, index) ->
  # determine how many samples we need
  num_samples = Math.min(Math.max(Math.round(dev * width * height * 0.1), 2), 20)

  # collect samples
  if num_samples > samples.length
    for i in [0...(num_samples - samples.length)]
      the_x = x + Math.random() * width
      the_y = y + Math.random() * height
      the_sample = sample(the_x, the_y)
      the_sample.x = the_x
      the_sample.y = the_y
      samples.push(the_sample)

  # average the samples
  average = new Color(0, 0, 0)
  for i in [0...samples.length]
    average.r += samples[i].r
    average.g += samples[i].g
    average.b += samples[i].b
  average.r /= samples.length
  average.g /= samples.length
  average.b /= samples.length

  # compute the deviation
  deviation = 0
  for i in [0...samples.length]
    deviation += Math.pow(samples[i].r - average.r, 2) + Math.pow(samples[i].g - average.g, 2) + Math.pow(samples[i].b - average.b, 2)
  deviation /= samples.length * 3

  # if the deviation is small, just render the average color
  if (deviation < 0.002) or width * height <= 100
    window.render_context.fillStyle = average.to_str()
    window.render_context.fillRect(x - 0.5, y - 0.5, width + 0.5, height + 0.5)
  else
    if width > height
      render_block(x,               y,                width * 0.5, height, samples.filter(((e) -> return e.x < x + width * 0.5)), deviation, index + 1)
      render_block(x + width * 0.5, y,                width * 0.5, height, samples.filter(((e) -> return e.x >= x + width * 0.5)), deviation, index + 1)
    else
      render_block(x,               y,                width, height * 0.5, samples.filter(((e) -> return e.y < y + height * 0.5)), deviation, index + 1)
      render_block(x,               y + height * 0.5, width, height * 0.5, samples.filter(((e) -> return e.y >= y + height * 0.5)), deviation, index + 1)

# render the scene
window.render = () ->
  # compute the left vector
  window.camera.left = window.camera.up.cross(window.camera.aim)

  # render the scene as a huge block
  window.render_context.fillStyle = "#fff"
  window.render_context.fillRect(render_x, render_y, render_width, render_height)
  render_block(render_x, render_y, render_width, render_height, [], 0.01, 0)
