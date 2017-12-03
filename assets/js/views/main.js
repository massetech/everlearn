export default class MainView {
  mount() {
    // This will be executed when the document loads...
    console.log('MainView mounted');
    $(document).ready(function() {
      // Set up select in materialize
      $('select').material_select()
      $('.empty_fields').click(function(){
        $('#search_form').clear().submit();
      });
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
  // setTimeout(function(){
  //   $('.flash_msg').fadeOut(800);
  //   //console.log("Flash fired Out");
  // }, 5000);
  console.log("Flash fired");
}

// let init_empty_fields = () => {
//   $('.empty_fields').click(function(){
//     // var form = document.forms;
//     // form[0].reset();
//     document.getElementById("search_form").reset();
//     // form[0].submit();
//   });
// }

jQuery.fn.clear = function(){
    var $form = $(this);
    $form.find('input:text, input:password, input:file, textarea').val('');
    $form.find('select option:selected').removeAttr('selected');
    $form.find('input:checkbox, input:radio').removeAttr('checked');
    return this;
};


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
