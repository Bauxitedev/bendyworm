extends Spatial




func _ready():
	
	var spikes = []
	spikes.append($SpikeRoot)
	

	for i in 30:
		var instance = $SpikeRoot.duplicate()
		spikes.append(instance)
		add_child(instance)
		
	var spike_count = len(spikes)
	for i in spike_count:
		
		var spike = spikes[i]
		var progress = i / float(spike_count)
		var angle = progress * PI * 2
		
		spike.rotate_z(angle + rand_range(-1,1) * (PI / float(spike_count)) )
		$Tween.interpolate_property(spike, "scale", Vector3(0,0,0), Vector3(1,1,1) * rand_range(0.4,1.0), rand_range(0.4,1.0),Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
		$Tween.start()
	
	#$SpikeRoot.queue_free()

