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
    color_factor = 0.2 + 0.8 * Math.pow(Math.sin((ray.origin.y + ray.dir.y * t) / 3), 2)
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