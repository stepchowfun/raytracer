# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

requestAnimFrame = window.requestAnimationFrame       ||
                   window.webkitRequestAnimationFrame ||
                   window.mozRequestAnimationFrame    ||
                   window.msRequestAnimationFrame     ||
                   (callback) -> window.setTimeout(callback, 1000 / 60)

$(document).ready(() ->
  # total framebuffer resolution
  width = null
  height = null

  # set the canvas size
  framebuffer = document.getElementById("framebuffer")
  context = framebuffer.getContext("2d")

  # resize handler
  $(window).resize(() ->
    width = $(window).innerWidth()
    height = $(window).innerHeight()
    framebuffer.width = width
    framebuffer.height = height
    window.device.width = width
    window.device.height = height
    $("#framebuffer").width($(window).innerWidth())
    $("#framebuffer").height($(window).innerHeight())
    window.camera.aspect = width / height
  )
  $(window).resize()

  # keyboard input
  key_w = false
  key_s = false
  key_a = false
  key_d = false
  key_up = false
  key_down = false
  key_left = false
  key_right = false
  $(window).keydown((e) ->
    if e.which == "W".charCodeAt(0)
      key_w = true
    if e.which == "S".charCodeAt(0)
      key_s = true
    if e.which == "A".charCodeAt(0)
      key_a = true
    if e.which == "D".charCodeAt(0)
      key_d = true
    if e.which == 38
      key_up = true
    if e.which == 40
      key_down = true
    if e.which == 37
      key_left = true
    if e.which == 39
      key_right = true
  )
  $(window).keyup((e) ->
    if e.which == "W".charCodeAt(0)
      key_w = false
    if e.which == "S".charCodeAt(0)
      key_s = false
    if e.which == "A".charCodeAt(0)
      key_a = false
    if e.which == "D".charCodeAt(0)
      key_d = false
    if e.which == 38
      key_up = false
    if e.which == 40
      key_down = false
    if e.which == 37
      key_left = false
    if e.which == 39
      key_right = false
  )

  # set up the scene
  device.context = context
  camera.pos.z = 1
  ground_size = 5
  fence_height = 3
  sky_height = 10
  scene_graph.push(new Plane(new Point(0, 0, sky_height), new Point(0, 0, -1), new Material(new Color(0, 0, 0), "sky.jpg", 0.05)))
  scene_graph.push(new Rectangle(new Point(-4 * ground_size, 2.35 * ground_size, 0), new Point(4 * ground_size, 2.35 * ground_size, 0), new Point(4 * ground_size, -2.35 * ground_size, 0), new Point(-4 * ground_size, -2.35 * ground_size, 0), new Material(new Color(0, 0, 0), "court.jpg", 1)))
  scene_graph.push(new Rectangle(new Point(-4 * ground_size, 2.35 * ground_size, fence_height), new Point(4 * ground_size, 2.35 * ground_size, fence_height), new Point(4 * ground_size, 2.35 * ground_size, 0), new Point(-4 * ground_size, 2.35 * ground_size, 0), new Material(new Color(0, 0, 0), "fence.jpg", 1)))
  scene_graph.push(new Rectangle(new Point(4 * ground_size, -2.35 * ground_size, fence_height), new Point(-4 * ground_size, -2.35 * ground_size, fence_height), new Point(-4 * ground_size, -2.35 * ground_size, 0), new Point(4 * ground_size, -2.35 * ground_size, 0), new Material(new Color(0, 0, 0), "fence.jpg", 1)))
  scene_graph.push(new Rectangle(new Point(-4 * ground_size, -2.35 * ground_size, fence_height), new Point(-4 * ground_size, 2.35 * ground_size, fence_height), new Point(-4 * ground_size, 2.35 * ground_size, 0), new Point(-4 * ground_size, -2.35 * ground_size, 0), new Material(new Color(0, 0, 0), "fence.jpg", 1)))
  scene_graph.push(new Rectangle(new Point(4 * ground_size, 2.35 * ground_size, fence_height), new Point(4 * ground_size, -2.35 * ground_size, fence_height), new Point(4 * ground_size, -2.35 * ground_size, 0), new Point(4 * ground_size, 2.35 * ground_size, 0), new Material(new Color(0, 0, 0), "fence.jpg", 1)))

  # camera state
  theta = 0
  phi = 0
  acceleration_factor = 100
  decceleration_factor = 20
  velocity = new Point(0, 0, 0)
  max_velocity = 16

  # the time when the last frame was rendered
  time = (new Date().getTime()) - 1000 / 30

  # desired framerate
  desired_fps = 25

  # render
  render_frame = () ->
    # calculate the time elapsed
    new_time = new Date().getTime()
    dt = Math.max(new_time - time, 1) * 0.001
    time = new_time

    # input
    acceleration = new Point(0, 0, 0)
    if key_w or key_up
      acceleration = acceleration.plus((new Point(Math.cos(theta), Math.sin(theta), 0)).times(max_velocity * 1.1).minus(velocity).normalized().times(acceleration_factor))
    if key_s or key_down
      acceleration = acceleration.plus((new Point(Math.cos(theta), Math.sin(theta), 0)).times(-max_velocity * 1.1).minus(velocity).normalized().times(acceleration_factor))
    if key_a
      acceleration = acceleration.plus((new Point(Math.cos(theta + Math.PI / 2), Math.sin(theta + Math.PI / 2), 0)).times(max_velocity * 1.1).minus(velocity).normalized().times(acceleration_factor))
    if key_d
      acceleration = acceleration.plus((new Point(Math.cos(theta + Math.PI / 2), Math.sin(theta + Math.PI / 2), 0)).times(-max_velocity * 1.1).minus(velocity).normalized().times(acceleration_factor))
    if acceleration.len() == 0
      if velocity.len() < decceleration_factor * dt
        velocity = new Point(0, 0, 0)
      else
        velocity = velocity.plus(velocity.normalized().times(-decceleration_factor * dt))
    else
      velocity = velocity.plus(acceleration.times(dt))
    if velocity.len() > max_velocity
      velocity = velocity.normalized().times(max_velocity)

    if key_left
      theta += 1.5 * dt
    if key_right
      theta -= 1.5 * dt
    #if key_up
    #  phi += 1.0 * dt
    #if key_down
    #  phi -= 1.0 * dt
    phi = Math.max(Math.min(phi, Math.PI / 2), -Math.PI / 2)

    # move the player
    camera.aim = new Point(Math.cos(theta) * Math.cos(phi), Math.sin(theta) * Math.cos(phi), Math.sin(phi))
    camera.left = new Point(Math.cos(theta + Math.PI / 2), Math.sin(theta + Math.PI / 2), 0)
    camera.up = new Point(Math.cos(theta) * Math.cos(phi + Math.PI / 2), Math.sin(theta) * Math.cos(phi + Math.PI / 2), Math.sin(phi + Math.PI / 2))
    camera.pos = camera.pos.plus(velocity.times(dt))

    if camera.pos.x < -4 * ground_size * 0.95
      camera.pos.x = -4 * ground_size * 0.95
    if camera.pos.x > 4 * ground_size * 0.95
      camera.pos.x = 4 * ground_size * 0.95
    if camera.pos.y < -2.35 * ground_size * 0.95
      camera.pos.y = -2.35 * ground_size * 0.95
    if camera.pos.y > 2.35 * ground_size * 0.95
      camera.pos.y = 2.35 * ground_size * 0.95

    device.quality *= 1 + Math.min(Math.max((1 / dt - desired_fps) * 0.01, -0.9), 0.9)
    device.quality = Math.min(Math.max(device.quality, 5), 100)

    # render the scene
    render()

    # ask the browser to render the next scene soon
    requestAnimFrame(render_frame)

  # render the first frame
  render_frame()
)
