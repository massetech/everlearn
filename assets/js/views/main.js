export default class MainView {
  mount() {
    // This will be executed when the document loads...
    console.log('MainView mounted');
    $(document).ready(function() {
      $('select').material_select();
      console.log('cooucou');
    });
  }

  unmount() {
    // This will be executed when the document unloads...
    console.log('MainView unmounted');
  }
}
