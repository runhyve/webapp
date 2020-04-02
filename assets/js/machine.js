import socket from "./socket"
import {
  put_flash,
  clear_flash,
  update_actions,
  update_status
} from './utils'

let channel = socket.channel("machine:" + machine.id, {})
channel.join()
  .receive("error", resp => {
    put_flash('error', 'Failed to connect to server: ' + resp.reason)
  })

window.setInterval(() => {
  channel.push("status")
}, 5000)

channel.on("status", payload => {
  clear_flash('error')

  if (payload.success) {
    document.querySelectorAll(`[data-machine-id="${payload.id}"]`).forEach((item) => {
      update_status(payload, item)
      update_actions(payload.actions, item)
    })
  } else {
    put_flash('error', payload.error)
  }
})