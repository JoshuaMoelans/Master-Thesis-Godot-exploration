extends TextEdit


signal reset_with_instances(count:int)

func _on_gui_input(event):
	if event is InputEventKey and event.keycode==KEY_ENTER:
		if self.get_text().is_valid_int():
			reset_with_instances.emit(int(self.get_text()))
		self.visible = false
		self.set_text("4")
