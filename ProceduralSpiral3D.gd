extends Node3D

var spiralPoints = []  # Array to store generated points

func _ready():
	generateSpiral()

func generateSpiral():
	var numPoints = 100  # Number of points in the spiral
	var spiralRadius = 10.0  # Initial radius of the spiral
	var spiralHeight = 1.0  # Height between each layer of the spiral
	var spiralAngularSpeed = 0.1  # Angular speed of the spiral

	for i in range(numPoints):
		# Calculate the position of each point in the spiral using polar coordinates
		var angle = i * spiralAngularSpeed
		var x = spiralRadius * cos(angle)
		var y = spiralRadius * sin(angle)

		# Create a Vector3 to represent the position of the point
		var point = Vector3(x, y, i * spiralHeight)

		# Store the point in the array
		spiralPoints.append(point)

		# Increase the radius for the next point (to create a spiral effect)
		spiralRadius += 0.1

	# Create a MeshInstance3D to visualize the spiral
	var spiralMesh = MeshInstance3D.new()
	spiralMesh.mesh = createSpiralMesh()
	add_child(spiralMesh)

func createSpiralMesh() -> ArrayMesh:
	# Create an array to store vertices
	var vertices = PackedVector3Array()

	# Add each point to the array
	for point in spiralPoints:
		vertices.append(point)

	# Create an ArrayMesh to represent the mesh
	var meshArray = ArrayMesh.new()
	meshArray.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, [vertices])

	return meshArray
