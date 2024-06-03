extends Label

var total_frames = 0
var total_fps = 0
var running_avg = 0

func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	
	total_frames += 1
	total_fps += fps
	
	running_avg = int(total_fps / total_frames)
	
	set_text("FPS: " + str(fps) + "\nAverage FPS: " + str(running_avg))
