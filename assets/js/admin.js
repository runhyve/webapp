import socket from "./socket"
import {put_flash,clear_flash,update_actions,update_status} from './utils'

let channel = socket.channel("machines:" + machines.ids, {})
channel.join()
  .receive("error", resp => { put_flash('error', 'Failed to connect to server: ' + resp.reason) })

window.setInterval(() => {
  channel.push("status")
}, 5000)

channel.on("status", payload => {
  clear_flash('error')

  if (payload.success) {
    payload.machines.forEach(function(machine_payload) {
      let context = document.getElementById('machine-' + machine_payload.id)
      update_status(machine_payload, context)
    })
  }
  else {
    put_flash('error', payload.error)
  }
})