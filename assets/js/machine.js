import socket from "./socket"
import {put_flash,clear_flash,update_actions,update_status} from './utils'

let channel = socket.channel("machine:" + machine.id, {})
channel.join()
  .receive("error", resp => { put_flash('error', 'Failed to connect to server: ' + resp.reason) })

window.setInterval(() => {
  channel.push("status")
}, 5000)

channel.on("status", payload => {
  clear_flash('error')

  if (payload.success) {
    update_status(payload)
    update_actions(payload.actions)
  }
  else {
    put_flash('error', payload.error)
  }
})