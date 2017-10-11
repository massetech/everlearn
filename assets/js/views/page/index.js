import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();

    // Specific logic here
    console.log('PageIndexView mounted');
    $("body").addClass("bg-img");
    $("nav").removeClass("has-shadow").addClass("back-transparent");
    $("footer").hide();
  }

  unmount() {
    super.unmount();

    // Specific logic here
    console.log('PageIndexView unmounted');
  }
}
