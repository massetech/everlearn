export default class MainView {
  mount() {
    // This will be executed when the document loads...
    // console.log('MainView mounted')
    $(document).ready(function() {
      $('select').material_select()
      $('.empty_fields').click(function(){
        $('#search_form').clear().submit()
      })
      init_flash()
      init_dropdown()
      init_toast()
      init_slidebars()
      // Assign global variable to support functions
      var global = (1,eval)('this')
    });
  }

  unmount() {
    // This will be executed when the document unloads...
    // console.log('MainView unmounted')
  }
}

// ------------- Methods  -----------------------------------------------------------------
global.choose_random = (list) => {
  return list[Math.floor(Math.random()*list.length)]
}

// Clear search fields
jQuery.fn.clear = function(){
    var $form = $(this)
    $form.find('input:text, input:password, input:file, textarea').val('')
    $form.find('select option:selected').removeAttr('selected')
    $form.find('input:checkbox, input:radio').removeAttr('checked')
    return this
};

// ------------- Initialization  -----------------------------------------------------------------
let init_slidebars= () => {
  $('#btn_slidebar_left').sideNav({
      menuWidth: 300, // Default is 300
      edge: 'left', // Choose the horizontal origin
      closeOnClick: true, // Closes side-nav on <a> clicks, useful for Angular/Meteor
      draggable: true // Choose whether you can drag to open on touch screens
    }
  )
  $('#btn_slidebar_right').sideNav({
      menuWidth: 300, // Default is 300
      edge: 'right', // Choose the horizontal origin
      closeOnClick: true, // Closes side-nav on <a> clicks, useful for Angular/Meteor
      draggable: true // Choose whether you can drag to open on touch screens
    }
  )
}

let init_toast= () => {
  $(document).on('click', '#toast-container .toast', function() {
    $(this).fadeOut(function(){
        $(this).remove()
    })
  })
}

let init_dropdown = () => {
  $(".dropdown-button").dropdown(
    { hover: true }
  );
}

let init_flash = () => {
  $('.flash_msg').hide()
  $('.flash_msg').click(function(){
    $(this).fadeOut( "slow", function() {
      // console.log("clicked")
    });
  });
  setTimeout(function(){
    $('.flash_msg').fadeIn(1000)
    //console.log("Flash fired In");
  }, 1000);
  setTimeout(function(){
    $('.flash_msg').fadeOut(800)
    //console.log("Flash fired Out");
  }, 5000)
  // console.log("Flash fired");
}
