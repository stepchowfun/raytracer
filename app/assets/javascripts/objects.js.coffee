class window.Sphere
  # constructor
  constructor: (@pos, @radius, @material) ->

  # intersect the object with a ray, returns a Hit object or null
  intersect: (ray) ->
    discriminant = Math.pow(ray.dir.dot(ray.origin.minus(@pos)), 2) - ray.origin.minus(@pos).len_sq() + Math.pow(@radius, 2)
    if discriminant < 0
      return null
    t1 = -ray.dir.dot(ray.origin.minus(@pos)) - Math.sqrt(discriminant)
    t2 = -ray.dir.dot(ray.origin.minus(@pos)) + Math.sqrt(discriminant)
    if t2 <= 0
      return null
    if t1 > 0
      t = t1
    else
      t = t2
    p = ray.origin.plus(ray.dir.times(t)).minus(@pos)
    return new Hit(t, 0.5 + Math.atan2(p.x, p.y) * 0.5 / Math.PI, 0.5 - Math.asin(p.z / @radius) / Math.PI, @material)

class window.Plane
  # constructor
  constructor: (@pos, @normal, @material) ->

  # intersect the object with a ray, returns a Hit object or null
  intersect: (ray) ->
    denom = ray.dir.dot(@normal)
    if denom == 0
      return null
    t = @pos.minus(ray.origin).dot(@normal) / denom
    if t <= 0
      return null
    p = ray.origin.plus(ray.dir.times(t))
    if @normal.z > 0.9 or @normal.z < -0.9
      n1 = @normal.cross(new Point(0, 1, 0)).normalized()
    else
      n1 = @normal.cross(new Point(0, 0, 1)).normalized()
    n2 = @normal.cross(n1)
    pp = p.minus(@pos)
    tx = pp.dot(n1)
    ty = pp.dot(n2)
    return new Hit(t, tx, ty, @material)

class window.Rectangle
  # constructor
  constructor: (@p1, @p2, @p3, @p4, @material) ->
    @normal = @p4.minus(@p1).cross(@p2.minus(@p1)).normalized()

  # intersect the object with a ray, returns a Hit object or null
  intersect: (ray) ->
    # proceed as if the rectangle was a plane
    denom = ray.dir.dot(@normal)
    if denom == 0
      return null
    t = @p1.minus(ray.origin).dot(@normal) / denom
    if t <= 0
      return null

    # make sure the intersection point is in the rectangle
    p = ray.origin.plus(ray.dir.times(t))
    if p.minus(@p1).dot(@p4.minus(@p1)) < 0
      return null
    if p.minus(@p2).dot(@p1.minus(@p2)) < 0
      return null
    if p.minus(@p3).dot(@p2.minus(@p3)) < 0
      return null
    if p.minus(@p4).dot(@p3.minus(@p4)) < 0
      return null

    # calculate the texture coordinates
    n1 = @p2.minus(@p1).normalized()
    n2 = @p4.minus(@p1).normalized()
    pp = p.minus(@p1)
    tx = pp.dot(n1) / @p2.minus(@p1).dot(n1)
    ty = pp.dot(n2) / @p4.minus(@p1).dot(n2)

    # return the hit
    return new Hit(t, tx, ty, @material)
