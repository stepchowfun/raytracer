# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

requestAnimFrame = window.requestAnimationFrame       ||
                   window.webkitRequestAnimationFrame ||
                   window.mozRequestAnimationFrame    ||
                   window.msRequestAnimationFrame     ||
                   (callback) -> window.setTimeout(callback, 1000 / 60)

$(document).ready(() ->
  # get the window size
  width = $(window).innerWidth()
  height = $(window).innerHeight()

  # set the canvas size
  framebuffer = document.getElementById("framebuffer")
  context = framebuffer.getContext("2d")
  framebuffer.width = width
  framebuffer.height = height

  # resize handler
  $(window).resize(() ->
    $("#framebuffer").width(100)
    $("#framebuffer").height(100)
    width = $(window).innerWidth()
    height = $(window).innerHeight()
    framebuffer.width = width
    framebuffer.height = height
    window.render_width = width
    window.render_height = height
    $("#framebuffer").width(width)
    $("#framebuffer").height(height)
    window.camera.aspect = width / height
  )

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
  window.render_context = context
  window.render_width = width
  window.render_height = height
  $("#framebuffer").width(width)
  $("#framebuffer").height(height)
  window.camera.aspect = width / height
  camera.pos.z = 1
  for i in [0...10]
    scene_graph.push(new Sphere(new Point(10, 9 - i * 2, 1), 1, new Color(Math.random(), Math.random(), Math.random())))
  scene_graph.push(new Sphere(new Point(10, 0, 0), 20, new Color(Math.random(), Math.random(), Math.random())))
  scene_graph.push(new Plane(new Point(0, 0, 0), new Point(0, 0, 1), new Color(0.2, 0.2, 0.2)))

  # camera state
  theta = 0
  phi = 0
  acceleration_factor = 100
  decceleration_factor = 20
  velocity = new Point(0, 0, 0)
  max_velocity = 16

  # the time when the last frame was rendered
  time = new Date().getTime()

  # render
  render_frame = () ->
    # calculate the time elapsed
    new_time = new Date().getTime()
    dt = Math.max(new_time - time, 1) * 0.001
    time = new_time

    # input
    acceleration = new Point(0, 0, 0)
    if key_w
      acceleration = acceleration.add(camera.aim.scaled(max_velocity * 1.1).subtract(velocity).normalized().scaled(acceleration_factor))
    if key_s
      acceleration = acceleration.add(camera.aim.scaled(-max_velocity * 1.1).subtract(velocity).normalized().scaled(acceleration_factor))
    if key_a
      acceleration = acceleration.add(camera.left.scaled(max_velocity * 1.1).subtract(velocity).normalized().scaled(acceleration_factor))
    if key_d
      acceleration = acceleration.add(camera.left.scaled(-max_velocity * 1.1).subtract(velocity).normalized().scaled(acceleration_factor))    
    if !key_w and !key_s and !key_a and !key_d
      if velocity.len() < decceleration_factor * dt
        velocity = new Point(0, 0, 0)
      else
        velocity = velocity.add(velocity.normalized().scaled(-decceleration_factor * dt))
    else
      velocity = velocity.add(acceleration.scaled(dt))
    if velocity.len() > max_velocity
      velocity = velocity.normalized().scaled(max_velocity)

    if key_left
      theta += 1.5 * dt
    if key_right
      theta -= 1.5 * dt
    if key_up
      phi += 1.5 * dt
    if key_down
      phi -= 1.5 * dt

    # move the player
    camera.aim = new Point(Math.cos(theta) * Math.cos(phi), Math.sin(theta) * Math.cos(phi), Math.sin(phi))
    camera.pos = camera.pos.add(velocity.scaled(dt))

    # render the scene
    render()

    # ask the browser to render the next scene soon
    requestAnimFrame(render_frame)

    # log the fps occasionally
    if Math.random() < 0.01
      console.log 1 / dt
  render_frame()
)
