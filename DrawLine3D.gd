extends Node2D

class Line:
	var Start
	var End
	var LineColor
	var Time
	
	func _init(Start, End, LineColor, Time):
		self.Start = Start
		self.End = End
		self.LineColor = LineColor
		self.Time = Time

var Lines = []
var RemovedLine = false

func _process(delta):
	for i in range(len(Lines)):
		Lines[i].Time -= delta
	
	if(len(Lines) > 0 || RemovedLine):
		update() #Calls _draw
		RemovedLine = false

func _draw():
	var Cam = get_viewport().get_camera()
	for i in range(len(Lines)):
		var ScreenPointStart = Cam.unproject_position(Lines[i].Start)
		var ScreenPointEnd = Cam.unproject_position(Lines[i].End)
		
		#Dont draw line if either start or end is considered behind the camera
		#this causes the line to not be drawn sometimes but avoids a bug where the
		#line is drawn incorrectly
		if(Cam.is_position_behind(Lines[i].Start) ||
			Cam.is_position_behind(Lines[i].End)):
			continue
		
		draw_line(ScreenPointStart, ScreenPointEnd, Lines[i].LineColor)
	
	#Remove lines that have timed out
	var i = Lines.size() - 1
	while (i >= 0):
		if(Lines[i].Time < 0.0):
			Lines.remove(i)
			RemovedLine = true
		i -= 1

func DrawLine(Start, End, LineColor, Time = 0.0):
	Lines.append(Line.new(Start, End, LineColor, Time))

func DrawRay(Start, Ray, LineColor, Time = 0.0):
	Lines.append(Line.new(Start, Start + Ray, LineColor, Time))

func DrawCube(Center, HalfExtents, LineColor, Time = 0.0):
	#Start at the 'top left'
	var LinePointStart = Center
	LinePointStart.x -= HalfExtents.x
	LinePointStart.y += HalfExtents.y
	LinePointStart.z -= HalfExtents.z
	
	#Draw top square
	var LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents.z * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(HalfExtents.x * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, -HalfExtents.z * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(-HalfExtents.x * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	
	#Draw bottom square
	LinePointStart = LinePointEnd + Vector3(0, -HalfExtents.y * 2.0, 0)
	LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents.z * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(HalfExtents.x * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, -HalfExtents.z * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(-HalfExtents.x * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	
	#Draw vertical lines
	LinePointStart = LinePointEnd
	DrawRay(LinePointStart, Vector3(0, HalfExtents.y * 2.0, 0), LineColor, Time)
	LinePointStart += Vector3(0, 0, HalfExtents.z * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents.y * 2.0, 0), LineColor, Time)
	LinePointStart += Vector3(HalfExtents.x * 2.0, 0, 0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents.y * 2.0, 0), LineColor, Time)
	LinePointStart += Vector3(0, 0, -HalfExtents.z * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents.y * 2.0, 0), LineColor, Time)


func DrawBoundWithRotation(bound:AABB, rotation, LineColor, Time = 0.0):
	var b_center = lerp(bound.position, bound.end, 0.5)
	var points = PoolVector3Array()
	points.resize(8)
	for i in range(8):
		points[i] = bound.get_endpoint(i) - b_center
	# two faces
	DrawLine(b_center + rotation * points[0], b_center + rotation * points[2], LineColor, Time)
	DrawLine(b_center + rotation * points[0], b_center + rotation * points[4], LineColor, Time)
	DrawLine(b_center + rotation * points[2], b_center + rotation * points[6], LineColor, Time)
	DrawLine(b_center + rotation * points[4], b_center + rotation * points[6], LineColor, Time)
	DrawLine(b_center + rotation * points[1], b_center + rotation * points[3], LineColor, Time)
	DrawLine(b_center + rotation * points[1], b_center + rotation * points[5], LineColor, Time)
	DrawLine(b_center + rotation * points[3], b_center + rotation * points[7], LineColor, Time)
	DrawLine(b_center + rotation * points[7], b_center + rotation * points[5], LineColor, Time)
	# connect them
	DrawLine(b_center + rotation * points[2], b_center + rotation * points[3], LineColor, Time)
	DrawLine(b_center + rotation * points[0], b_center + rotation * points[1], LineColor, Time)
	DrawLine(b_center + rotation * points[6], b_center + rotation * points[7], LineColor, Time)
	DrawLine(b_center + rotation * points[4], b_center + rotation * points[5], LineColor, Time)
