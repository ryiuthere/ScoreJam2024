extends Timer

var _target_direction : String

func double_tap(direction: String) -> bool:
	if direction == _target_direction and time_left > 0:
		return true
	else:
		_target_direction = direction
		start(wait_time)	
	return false
