import socket from "./socket"
import {put_flash,clear_flash,update_actions,update_status} from './utils'

let channel = socket.channel("team:" + team.id, {})
channel.join()
  .receive("error", resp => { put_flash('error', 'Failed to connect to server: ' + resp.reason) })

window.setInterval(() => {
  channel.push("status_team")
}, 5000)

channel.on("status_team", payload => {
  clear_flash('error')

  if (payload.success) {
    payload.machines.forEach(function(machine_payload) {
      let context = document.getElementById('machine-' + machine_payload.id)
      update_status(machine_payload, context)
      // update_actions(payload.actions, context)
    })
  }
  else {
    put_flash('error', payload.error)
  }
})