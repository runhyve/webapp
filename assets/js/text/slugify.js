import { slugify as make_slug } from 'transliteration';

function slugify() {
  document.querySelectorAll('[data-slugify]').forEach((slug_field) => {
    let base_field = document.querySelector('[name="' + slug_field.dataset.slugify + '"]')
    let parent = slug_field.parentElement
    let value = base_field.value

    if (!parent.querySelector('span.slugify')) {
      let slug_text = document.createElement('span')
      slug_text.classList.add('slugify')
      slug_text.textContent = value
      parent.appendChild(slug_text)

      slug_field.classList.add('is-hidden')
    }

    ['keyup', 'change'].forEach((event_type) => {
      base_field.addEventListener(event_type, () => {
        let slug = make_slug(base_field.value)
        let slug_text = parent.querySelector('span.slugify')
        slug_text.textContent = slug
        slug_field.value = slug
      })
    })
  })
}

export default slugify;