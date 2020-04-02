/**
 * Puts flash message into #notifications placeholder.
 *
 * @param key
 * @param message
 */
export function put_flash(key, message) {
  const color = {
    info: "info",
    error: "danger"
  };

  Bulma.create('notification', {
    body: message,
    parent: document.getElementById('notifications'),
    color: color[key],
    isDismissable: true
  }).show();
}

/**
 * Removes flash message for given key.
 * @param key
 */
export function clear_flash(key) {
  const css_classes = {
    info: "is-info",
    error: "is-danger"
  };

  let notitications = document.getElementById('notifications');
  let wrapper = notitications.querySelector("." + css_classes[key]);

  if (wrapper) {
    notitications.removeChild(wrapper)
  }
}

/**
 * Updates status, colors and icon.
 *
 * @param payload
 */
export function update_status(payload, context) {
  context.querySelectorAll('span.status').forEach((item) => {
    if (item.classList.contains('status-icon')) {
      item.childNodes.item(0).className = payload.icon
    } else {
      item.textContent = payload.status
    }

    item.classList.remove(item.dataset.status)
    item.classList.add(payload.status_css)
    item.dataset.status = payload.status_css
  });
}

/**
 * Shows and hides actions depending on status.
 *
 * @param actions
 */
export function update_actions(actions, context) {
  for (var action in actions) {
    if (actions.hasOwnProperty(action)) {
      context.querySelectorAll(".action-" + action).forEach((item) => {
        if (actions[action] === true) {
          item.classList.remove('is-hidden')
        } else {
          item.classList.add('is-hidden')
        }
      })
    }
  }
}