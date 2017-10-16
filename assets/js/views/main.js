export default class MainView {
  mount() {
    // This will be executed when the document loads...
    console.log('MainView mounted');
    $(document).ready(function() {
      // Set up select in materialize
      $('select').material_select()
      init_flash()
    });
  }

  unmount() {
    // This will be executed when the document unloads...
    console.log('MainView unmounted');
  }
}

// ------------- Methods

let init_flash = () => {
  $('.flash_msg').hide()
  $('.flash_msg').click(function(){
    $(this).fadeOut( "slow", function() {
      console.log("clicked");
    });
  });
  setTimeout(function(){
    $('.flash_msg').fadeIn(1000);
    //console.log("Flash fired In");
  }, 1000);
  setTimeout(function(){
    $('.flash_msg').fadeOut(1000);
    //console.log("Flash fired Out");
  }, 5000);
  console.log("Flash fired");
}
