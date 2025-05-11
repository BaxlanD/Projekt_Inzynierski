extends Resource
class_name NavGraph

## This should be Array of POSITIONS where points are
## When resource used to generate graph,
## their index in this array is used as point ID
@export var points: Array[Vector2]

## This should be Array of ID's between which there is a connection
## ID's of points are determined based on their order in points Array
@export var edges: Array[Vector2i]
