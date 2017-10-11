// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

import "phoenix_html";
import loadView from './views/loader';
import "hammerjs";
import "materialize-css";
// import "swiper";
// import "unpoly";

function handleDOMContentLoaded() {
  // Get the current view name
  const viewName = document.getElementsByTagName('body')[0].dataset.jsViewName;

  // Load view class and mount it
  const ViewClass = loadView(viewName);
  const view = new ViewClass();
  view.mount();

  window.currentView = view;
}

function handleDocumentUnload() {
  window.currentView.unmount();
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
window.addEventListener('unload', handleDocumentUnload, false);
