/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */

/**
 * Search function
 */

const searchInput = document.querySelector("#searchbar > input")
const searchButton = document.querySelector("#searchbar > button")

const lookup = {"/":"/","deepl":"https://deepl.com/","reddit":"https://reddit.com/","maps":"https://maps.google.com/"}
const engine = "startpage"
const engineUrls = {
  deepl: "https://www.deepl.com/translator#-/-/{query}",
  duckduckgo: "https://duckduckgo.com/?q={query}",
  ecosia: "https://www.ecosia.org/search?q={query}",
  google: "https://www.google.com/search?q={query}",
  startpage: "https://www.startpage.com/search?q={query}",
  youtube: "https://www.youtube.com/results?q={query}",
}

const isWebUrl = value => {
  try {
    const url = new URL(value)
    return url.protocol === "http:" || url.protocol === "https:"
  } catch {
    return false
  }
}

const getTargetUrl = value => {
  if (isWebUrl(value)) return value
  if (lookup[value]) return lookup[value]
  const url = engineUrls[engine] ?? engine
  return url.replace("{query}", value)
}

const search = () => {
  const value = searchInput.value
  const targetUrl = getTargetUrl(value)
  window.open(targetUrl, "_self")
}

searchInput.onkeyup = event => event.key === "Enter" && search()
searchButton.onclick = search

/**
 * inject bookmarks into html
 */

const bookmarks = [{"id":"GOH9oPh6RNmfwgUh","label":"school","bookmarks":[{"id":"CVEQjqk81G4FEt2O","label":"canvas","url":"https://canvas.du.edu/"},{"id":"DG3xLuQIZ9XyRDJv","label":"my du","url":"https://my.du.edu/dashboard"},{"id":"cB9701V3qAYD41wV","label":"accudemia","url":"https://du.accudemia.net"}]},{"id":"nq2ixhiAbGI4GO6b","label":"music","bookmarks":[{"id":"LA3HyHa3Msz4ggks","label":"aoty","url":"https://www.albumoftheyear.org/"},{"id":"O49Bi0AtuUu8yx40","label":"rym","url":"https://rateyourmusic.com/"},{"id":"mpnsKxlESQgCEWLJ","label":"last.fm","url":"https://www.last.fm/user/being_pool"}]},{"id":"OxiLqltXXfpZl7dL","label":"utils","bookmarks":[{"id":"B8tAmjcad9A6uAB2","label":"syncthing","url":"http://127.0.0.1:8384/"},{"id":"F7XYJkDl2nbLzSJX","label":"github","url":"https://github.com/flatrat24"},{"id":"gcElERi8vFWROq96","label":"chatgpt","url":"https://chatgpt.com/"}]}]

const createGroupContainer = () => {
  const container = document.createElement("div")
  container.className = "bookmark-group"
  return container
}

const createGroupTitle = title => {
  const h2 = document.createElement("h2")
  h2.innerHTML = title
  return h2
}

const createBookmark = ({ label, url }) => {
  const li = document.createElement("li")
  const a = document.createElement("a")
  a.href = url
  a.innerHTML = label
  li.append(a)
  return li
}

const createBookmarkList = bookmarks => {
  const ul = document.createElement("ul")
  bookmarks.map(createBookmark).forEach(li => ul.append(li))
  return ul
}

const createGroup = ({ label, bookmarks }) => {
  const container = createGroupContainer()
  const title = createGroupTitle(label)
  const bookmarkList = createBookmarkList(bookmarks)
  container.append(title)
  container.append(bookmarkList)
  return container
}

const injectBookmarks = () => {
  const bookmarksContainer = document.getElementById("bookmarks")
  bookmarksContainer.append()
  bookmarks.map(createGroup).forEach(group => bookmarksContainer.append(group))
}

injectBookmarks()
