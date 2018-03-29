export default class MainView {
  mount() {
    // This will be executed when the document loads...
    console.log('MainView mounted')
    $(document).ready(function() {
      $('select').material_select()
      $('.empty_fields').click(function(){
        $('#search_form').clear().submit()
      })
      init_flash()
      init_dropdown()
      init_toast()
      window.slidebars_controller = init_slidebars()
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
      console.log("clicked")
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

// // Set up slidebars
let init_slidebars = () => {
  var controller = new slidebars;
  // console.log( controller )
  controller.init(
    console.log( 'Slidebars has been initialized.' )
  )
  $("#slidebar_container").on( 'click', function () {
    controller.close( function () {
      console.log( 'Closed all Slidebars.' )
    } )
  } )
  return controller
}


// let init_empty_fields = () => {
//   $('.empty_fields').click(function(){
//     // var form = document.forms;
//     // form[0].reset();
//     document.getElementById("search_form").reset();
//     // form[0].submit();
//   });
// }

// // Validate fields are not empty
//  $("#formValidate").validate({
//     rules: {
//         uname: {
//             required: true,
//             minlength: 5
//         },
//         cemail: {
//             required: true,
//             email:true
//         },
//         password: {
// 		required: true,
// 		minlength: 5
// 	},
// 	cpassword: {
// 		required: true,
// 		minlength: 5,
// 		equalTo: "#password"
// 	},
// 	curl: {
//             required: true,
//             url:true
//         },
//         crole:"required",
//         ccomment: {
// 		required: true,
// 		minlength: 15
//         },
//         cgender:"required",
// 	cagree:"required",
//     },
//     //For custom messages
//     messages: {
//         uname:{
//             required: "Enter a username",
//             minlength: "Enter at least 5 characters"
//         },
//         curl: "Enter your website",
//     },
//     errorElement : 'div',
//     errorPlacement: function(error, element) {
//       var placement = $(element).data('error');
//       if (placement) {
//         $(placement).append(error)
//       } else {
//         error.insertAfter(element);
//       }
//     }
//  });
