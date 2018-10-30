import socket from "./socket"

let channel = socket.channel("machine:" + machine.id, {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

window.setInterval(() => {
  channel.push("status")
}, 5000)

channel.on("status", payload => {
  update_buttons(payload.actions)
  update_status(payload)
})

function update_status(payload) {
  document.querySelectorAll('span.status').forEach((item) => {
    if (item.classList.contains('status-icon')) {
      item.childNodes.item(0).className = payload.icon
    }
    else {
      item.textContent = payload.status
    }

    item.classList.remove(item.dataset.status)
    item.classList.add(payload.status_css)
    item.dataset.status = payload.status_css
  });
}

function update_buttons(actions) {
  for (var action in actions) {
    if (actions.hasOwnProperty(action)) {
      document.querySelectorAll("a.action-" + action).forEach((item) => {
        if (actions[action] === true) {
          item.parentElement.classList.remove('is-hidden')
        }
        else {
          item.parentElement.classList.add('is-hidden')
        }
      })
    }
  }
}