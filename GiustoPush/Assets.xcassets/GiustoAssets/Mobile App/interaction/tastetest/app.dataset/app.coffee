# Create Base
background = new BackgroundLayer backgroundColor: "#f6f8fa"

title = new Layer
	x: 0, y: 0, width: 640, height: 130, image:"images/title.png"
	
tabBar = new Layer
	x: 0, y: 1036, width: 640, height: 100, image:"images/tabbar.png"

# Create Next Image
nextImage = new Layer
	x: 0, y: 0, width: 420, height: 508, image:"images/nextimage.png"
	
nextImage.center()
nextImage.scale = 0.8
nextImage.opacity = 0.5
nextImage.style = borderRadius: "9px"
nextImage.shadowColor = "rgba(0, 0, 0, 0.05)"
nextImage.shadowBlur = 3
nextImage.shadowY = 2
nextImage.shadowX = 0
nextImage = 1

# Create Main Image
mainImage = new Layer
	x: 0, y: 0, width: 420, height: 508, image:"images/mainimage.png"
	
mainImage.center()
mainImage.style = borderRadius: "9px"
mainImage.shadowColor = "rgba(0, 0, 0, 0.05)"
mainImage.shadowBlur = 3
mainImage.shadowY = 2
mainImage.shadowX = 0
mainImage.shadowSpread = 1
mainImage.draggable.enabled = true

# Create Actions
noThanks = new Layer
	x: 0, y: 130, width: 88, height: 906, image:"images/nothanks.png"

yesPlease = new Layer
	x: 554, y: 130, width: 88, height: 906, image:"images/yesplease.png"
	
skip = new Layer
	x: 0, y: 130, width: 640, height: 88, image:"images/skip.png"

comment = new Layer
	x: 0, y: 948, width: 640, height: 88, image:"images/comment.png"
	
# Hide Actions
noThanks.opacity = 0
yesPlease.opacity = 0
skip.opacity = 0
comment.opacity = 0

# Reset Drag
originalX = mainImage.x
originalY = mainImage.y
springCurve = "spring(200,20,10)"

# Swipe
mainImage.on Events.DragMove, ->
		
	if mainImage.x < 70
		mainImage.animate
			properties:
				rotation: -10
			curve: springCurve
		noThanks.animate
			properties:
				opacity: 1
			curve: springCurve
	else if mainImage.x > 170
		mainImage.animate
			properties:
				rotation: 10
			curve: springCurve
		yesPlease.animate
			properties:
				opacity: 1
			curve: springCurve
	else if mainImage.y < 200
		skip.animate
			properties:
				opacity: 1
			curve: springCurve
	else if mainImage.y > 450
		comment.animate
			properties:
				opacity: 1
			curve: springCurve
	else
		mainImage.animate
			properties:
				rotation: 0
			curve: springCurve
	
mainImage.on Events.DragEnd, ->
  if mainImage.x > 400
    mainImage.animate
      properties:
        x: 700
      curve: "ease"
      time: 0.15
  else if mainImage.x < -200
    mainImage.animate
      properties:
        x: -700
      curve: "ease"
      time: 0.15
  else if mainImage.y < -80
    mainImage.animate
      properties:
        y: -1000
      curve: "ease"
      time: 0.15
  else if mainImage.y > 700
    mainImage.animate
      properties:
        y: 1500
      curve: "ease"
      time: 0.15
    # keyboard & comment
  else
    mainImage.animate
      properties:
        x: originalX
        y: originalY
        rotation: 0
      curve: springCurve
    noThanks.animate
      properties:
        opacity: 0
      curve: springCurve
    yesPlease.animate
      properties:
        opacity: 0
      curve: springCurve
    skip.animate
      properties:
        opacity: 0
      curve: springCurve
    comment.animate
      properties:
        opacity: 0
      curve: springCurve
# Swipe Left

# Swipe Right

# Swipe Up

# Swipe Down

# Next Image
title.bringToFront()
tabBar.bringToFront()