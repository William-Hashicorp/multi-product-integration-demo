output "nomad_servers_target_id" {
  value       = boundary_target.nomad_servers.id
  description = "The ID of the Boundary target for Nomad Servers."
}

output "nomad_nodes_x86_target_id" {
  value       = boundary_target.nomad_nodes_x86.id
  description = "The ID of the Boundary target for Nomad x86 Nodes."
}

output "nomad_nodes_arm_target_id" {
  value       = boundary_target.nomad_nodes_arm.id
  description = "The ID of the Boundary target for Nomad Arm Nodes."
}
