import VHChromeFix from '../addons/mobile-chrome-vh-fix';

export default class MainView {
  mount() {
    // This will be executed when the document loads...
    console.log('MainView mounted')
    $(document).ready(function() {
      init_navigation()
      init_flash()
      init_dropdown()
      init_toast()
      init_slidebars()
      init_mobile_chrome_vh_fix()
      // Assign global variable to support functions
      var global = (1,eval)('this')
    });
  }

  unmount() {
    // This will be executed when the document unloads...
    console.log('MainView unmounted')
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
let init_navigation = () => {
  $('select').material_select()
  $('.empty_fields').click(function(){
    $('#search_form').clear().submit()
  })
}

let init_slidebars = () => {
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
  console.log("Sidebars mounted")
}
let destroy_slidebars= () => {
  $('#btn_slidebar_left').sideNav('destroy')
  $('#btn_slidebar_right').sideNav('destroy')
  console.log("Sidebars destroyed")
}

let init_toast= () => {
  $(document).on('click', '#toast-container .toast', function() {
    $(this).fadeOut(function(){
      // hide the toast bu dont remove it since Materialize will do it later
      // See in fhash function
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
  $('.flash_msg').on('touchstart click', function() {
    $(this).fadeOut( "slow", function() {
      // console.log("clicked")
    });
  });
  setTimeout(function(){
    $('.flash_msg').fadeIn(1000)
    console.log("Flash fired In");
  }, 1000);
  setTimeout(function(){
    $('.flash_msg').fadeOut(800)
    //console.log("Flash fired Out");
  }, 5000)
  // console.log("Flash fired");
}

let init_mobile_chrome_vh_fix = () => {
  var vhFix = new VHChromeFix([
    {
      selector: '.player',
      vh: 100
    },
    {
      selector: '.Foxes',
      vh: 50
    }
  ]);
}
