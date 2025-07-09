extends Node

const COMPONENTS_NODE_NAME := "Components"
const COMPONENTS := {
	# Not using enums since godot doesnt allow string values
	HEALTH = "HealthComponent",
}

static func get_component(body: Node, component_name: String) -> Node:
	var body_components := body.get_node(COMPONENTS_NODE_NAME)
	
	if( not body_components or
		not body_components.has_node(component_name) ):
		return null
	
	return body_components.get_node(component_name)

static func get_component_parent(component: Node) -> Node:
	return component.get_parent().get_parent()
