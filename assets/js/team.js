import socket from "./socket"
import {
  put_flash,
  clear_flash,
  update_actions,
  update_status
} from './utils'

let channel = socket.channel("team:" + team.id, {})
channel.join()
  .receive("error", resp => {
    put_flash('error', 'Failed to connect to server: ' + resp.reason)
  })

window.setInterval(() => {
  channel.push("status_team")
}, 5000)

channel.on("status_team", payload => {
  clear_flash('error')

  if (payload.success) {
    payload.machines.forEach(function (machine_payload) {
      document.querySelectorAll(`[data-machine-id="${machine_payload.id}"]`).forEach((item) => {
        update_status(machine_payload, item)
        update_actions(machine_payload.actions, item)
      })
    })
  } else {
    put_flash('error', payload.error)
  }
})