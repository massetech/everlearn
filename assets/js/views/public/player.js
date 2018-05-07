import MainView from '../main'

export default class View extends MainView {
  mount() {
    super.mount()
    // console.log('PublicPlayerView mounted')
    init_player_data()
    init_slidebar_functions()
    init_action_btns()
    init_progress_bar()
    play_new_card()
  }

  unmount() {
    super.unmount()
    // console.log('PublicPlayerView unmounted')
  }
}

// ------------- Initialization  -----------------------------------------------------------------
let init_player_data = () => {
  var data = JSON.parse(window.Gon.assets().json_data)
  window.everlearn = []
  window.everlearn.token = data.token
  window.everlearn.api_url = window.Gon.assets().api_url
  window.everlearn.nb_change = 0
  window.everlearn.content = data.content
  window.everlearn.learning_mode = "question_or_answer"
  window.everlearn.classroom_index = 0
  window.everlearn.classroom_id = data.content.classrooms[0].id
  window.everlearn.membership_index = 0
  window.everlearn.membership_id = data.content.classrooms[0].memberships[0].id
  update_membership_and_classroom(window.everlearn.classroom_id, window.everlearn.membership_id)
}

let update_user_data = (new_data) => {
  window.everlearn.nb_change = 0
  window.everlearn.content = new_data
  console.log("data updated")
  $("i.ok").removeClass("hide")
  $("i.nok, i.pb").addClass("hide")

  // var old_content = window.everlearn.content
  // // Check if a page refresh is needed
  // for (let i = 0; i < old_content.classrooms.length; i++) {
  //   var classroom = old_content.classrooms[i]
  //   // Check Classroom already existed
  //   var updated_cl_index = old_content.classrooms.findIndex(x => x.id == classroom.id)
  //   if (updated_cl_index == undefined) {
  //     break
  //     window.location.reload(true)
  //   } else {
  //     for (let j = 0; j < classroom.memberships.length; j++) {
  //       var membership = classroom.memberships[j]
  //       // Check Membership already existed
  //       var updated_mb_index = old_content.classrooms[updated_cl_index].memberships.findIndex(x => x.id == membership.id)
  //       if (updated_mb_index == undefined) {
  //         break
  //         window.location.reload(true)
  //       }
  //     }
  //   }
  // }
  // No page refresh is needed

}

let init_action_btns = () => {
  $("#btn-renew").on('touchstart click', function() {
    action_on_card('renew')
    event.stopPropagation()
    event.preventDefault()
  })
  $("#btn-known").on('touchstart click', function() {
    action_on_card('up')
    event.stopPropagation()
    event.preventDefault()
  })
  $("#btn-warning").on('touchstart click', function() {
    add_warning_to_card()
    event.stopPropagation()
    event.preventDefault()
  })
  $(".slide-item").on('touchstart click', function() {
    show_answers()
    event.stopPropagation()
    event.preventDefault()
  })
}

let init_slidebar_functions = () => {
  $(".toogle_mbs_change").on('touchstart click', function() {
    update_membership_and_classroom(this.dataset.classroom_id, this.dataset.membership_id)
    play_new_card()
  })
  $(".toogle_question_change").on('touchstart click', function() {
    window.everlearn.learning_mode = this.dataset.learning_mode
    play_new_card()
  })
  $(".toogle_api").on('touchstart click', function() {
    call_everlearn_api()
    play_new_card()
  })
  $(".reset_data").on('touchstart click', function() {
    reset_membership_data()
    play_new_card()
  })
}

let init_progress_bar = () => {
  let array = window.everlearn.content.classrooms.map((c) => c.memberships.map((mb) => mb))
  let memberships = [].concat(...array)
  console.log(memberships)
  memberships.forEach(function(membership){
    update_progress_bar(`menu_bar_${membership.id}`, membership.cards)
  })
}

// ------------- Methods  -----------------------------------------------------------------
let add_warning_to_card = () => {
  var new_card = window.everlearn.playing_card
  var card_index = window.everlearn.playing_card_index
  new_card.user_alert = true
  update_card(card_index, new_card)
  $("#btn-warning").addClass("disabled")
}

let update_card = (card_index, new_card) => {
  var classroom_index = window.everlearn.classroom_index
  var membership_index = window.everlearn.membership_index
  var card = window.everlearn.content.classrooms[classroom_index].memberships[membership_index].cards[card_index]
  // Change fields that were updated (only !)
  card.status = new_card.status
  card.nb_downgrade = new_card.nb_downgrade
  card.nb_practice = new_card.nb_practice
  card.nb_view = new_card.nb_view
  card.user_alert = new_card.user_alert
  check_need_for_update()
  // Replace the object in window main object
  window.everlearn.content.classrooms[classroom_index].memberships[membership_index].cards[card_index] = card
  console.log(`Card updated ${card.id}`)
}

let check_need_for_update = () => {
  var nb_change = window.everlearn.nb_change
  if (navigator.onLine == true && nb_change > 10) {
    call_everlearn_api()
  }
  else if (navigator.onLine == false && nb_change > 10) {
    $("i.nok").removeClass("hide")
    $("i.ok, i.pb").addClass("hide")
  }
  else {window.everlearn.nb_change = nb_change + 1}
}

let action_on_card = (action) => {
  var card = window.everlearn.playing_card
  var card_index = window.everlearn.playing_card_index
  let status = card.status
  let nb_practice = card.nb_practice
  let nb_view = card.nb_view
  let nb_downgrade = card.nb_downgrade
  // Card udpate algorythm
  if (status == 0) {card.status = 1;card.nb_practice = nb_practice + 1;}
  else if (status == 1 && action == "up" && nb_practice >= 3) {card.status = 2;card.nb_practice = 0;}
  else if (status == 1 && action == "up") {card.nb_practice = nb_practice + 1;}
  else if (status == 1 && action == "renew") {/* do nothing */}
  else if (status == 2 && action == "up" && nb_practice >= 2) {card.status = 3;card.nb_practice = 0;}
  else if (status == 2 && action == "up") {card.nb_practice = nb_practice + 1;}
  else if (status == 2 && action == "renew") {/* do nothing */}
  else if (status == 3 && action == "renew") {card.status = 2;card.nb_view = nb_view + nb_practice;card.nb_downgrade = nb_downgrade + 1;card.nb_practice = 0;}
  else if (status == 3 && action == "up") {nb_view = nb_view - 1}
  card.nb_view = nb_view + 1
  update_card(card_index, card)
  play_new_card()
}

let reset_membership_data = () => {
  var card_list = get_actual_cards_list()
  for (let i = 0; i < card_list.length; i++) {
    var card = card_list[i]
    card.status = 0
    // We dont reinitialize nb of views
    card_list[i] = card
  }
  play_new_card()
}

let get_actual_cards_list = () => {
  var classroom_index = window.everlearn.classroom_index
  var membership_index = window.everlearn.membership_index
  return window.everlearn.content.classrooms[classroom_index].memberships[membership_index].cards
}

let play_new_card = () => {
  $(`.slide-item`).fadeOut(500, function() {
    // Algorythm to choose new card
    var learning_mode = window.everlearn.learning_mode
    var cards_list = get_actual_cards_list()
    var previous_cards = window.everlearn.previous_cards || [0, 0] // Keep modulo 2
    var n = Math.random()
    var p = cards_list.filter(card => card.status == 0).length
    var m = cards_list.filter(card => card.status == 1).length
    var q = cards_list.filter(card => card.status == 2).length
    var r = cards_list.filter(card => card.status == 3).length
    // console.log("n = " + n)
    // console.log("p = " + p)
    // console.log("m = " + m)
    // console.log("q = " + q)
    // console.log("r = " + r)
    if (p > 0 && m < 20) {var status = 0} // We maintain m new cards in the deck
    else if (m > 0 && n < 0.75) {var status = 1}
    else if (q > 0 && n < 0.90) {var status = 2}
    else if (r > 0) {var status = -1} // Fallback to any card in the list
    // console.log("status = "+ status)
    // console.log(cards_list)
    if (status >= 0 && learning_mode != "fast-track") {
      var filtered_list = cards_list.filter(card => card.status == status)
      var new_card = filtered_list[Math.floor(Math.random() * filtered_list.length)]
    } else { // There was a problem or fast-track : choose randomly in the list
      var new_card = cards_list[Math.floor(Math.random() * cards_list.length)]
    }
    if (previous_cards.includes(new_card.id)) { // Control on previous cards to avoid the same twice
      new_card = cards_list[Math.floor(Math.random() * cards_list.length)]
    }

    // Update datas with new card
    var classroom_index = window.everlearn.classroom_index
    var membership_index = window.everlearn.membership_index
    var membership_id = window.everlearn.content.classrooms[classroom_index].memberships[membership_index].id
    window.everlearn.playing_card = new_card
    window.everlearn.playing_card_index = window.everlearn.content.classrooms[classroom_index].memberships[membership_index].cards.findIndex(x => x.id == new_card.id)
    previous_cards.push(new_card.id)
    const [head, ...tail] = previous_cards
    window.everlearn.previous_cards = tail
    console.log(`new card played : card_id = ${new_card.id}`)
    update_player(new_card)
    update_progress_bar("player_bar", cards_list)
    // update also for membership menu in nav bar
    update_progress_bar(`menu_bar_${membership_id}` , cards_list)
    // `menu_bar_${membership_id}`
  })
}

let update_player = (new_card) => {
  var learning_mode = window.everlearn.learning_mode
  const cases = {
    "question_or_answer": new_card[choose_random([`question`, `answer`])],
    "fast-track": new_card[choose_random([`question`, `answer`])],
    "question": new_card.question,
    "answer": new_card.answer,
    "sound": new_card.sound
  }
  var new_question = cases[learning_mode]
  // console.log(`new_question : ${new_question}`)
  $(`.slide-item`).find('.asked').text(new_question)
  $(`.slide-item`).find('.card_question').text(`${new_card.question}`)
  $(`.slide-item`).find('.card_answer').text(`${new_card.answer}`)
  $(`.slide-item`).find('.card_phonetic').text(`${new_card.phonetic}`)
  $(`.slide-item`).find('.question').removeClass(`hide`)
  $(`.slide-item`).find('.answer').addClass(`hide`)
  hide_answers()
  $(`.slide-item`).fadeIn(500)
  if (new_card.user_alert == true) {
    $("#btn-warning").addClass("disabled")
  } else {
    $("#btn-warning").removeClass("disabled")
  }
}

let show_answers = () => {
  $(`.slide-item`).find('.question').addClass(`hide`)
  $(`.slide-item`).find('.answer').removeClass(`hide`)
}

let hide_answers = () => {
  $(`.slide-item`).find('.answer').addClass(`hide`)
  $(`.slide-item`).find('.question').removeClass(`hide`)
}

// let update_progress_bar = (bar_id, cards_list) => {
//   var total = cards_list.length
//   var level1_share = cards_list.filter(card => card.status == 1).length / total * 100
//   var level2_share = cards_list.filter(card => card.status == 2).length / total * 100
//   var level3_share = cards_list.filter(card => card.status == 3).length / total * 100
//   var level0_share = 100 - level1_share - level2_share - level3_share
//   // console.log(total)
//   console.log([level0_share, level1_share, level2_share, level3_share])
//   // console.log("level0_share : " + level0_share + ", level1_share : " + level1_share + ", level2_share : " + level2_share)
//   console.log(bar_id)
//   $(`#${bar_id}`).find('.level0').css('width', level0_share + '%')
//   $(`#${bar_id}`).find('.level1').css('width', level1_share + '%')
//   $(`#${bar_id}`).find('.level2').css('width', level2_share + '%')
//   $(`#${bar_id}`).find('.level3').css('width', level3_share + '%')
//   // The bar is ordered : next div is the previous level...
//   $("#player_bar > .progress-item").each(function(){
//     if ($(this).next(".progress-item").width() > 0) {
//       $(this).removeClass("right_corner")
//     } else {
//       $(this).addClass("right_corner")
//     }
//     if ($(this).prev(".progress-item").width() > 0) {
//       $(this).removeClass("left_corner")
//     } else {
//       $(this).addClass("left_corner")
//     }
//   });
// }

let update_membership_and_classroom = (classroom_id, membership_id) => {
  var classroom_index = window.everlearn.content.classrooms.findIndex(x => x.id == classroom_id)
  var classroom = window.everlearn.content.classrooms[classroom_index]
  var membership_index = classroom.memberships.findIndex(x => x.id == membership_id)
  var membership = classroom.memberships[membership_index]
  var nb_cards = membership.cards.length
  var membership = classroom.memberships.find(x => x.id == membership_id)
  window.everlearn.classroom_index = classroom_index
  window.everlearn.classroom_id = classroom.id
  window.everlearn.membership_index = membership_index
  window.everlearn.membership_id = membership.id
  window.everlearn.learning_mode = "question_or_answer"
  $(`#classroom_title`).text(`${classroom.title}`)
  $(`#membership_title`).text(`${membership.title} (${nb_cards})`)
  $(".mbs_menu").addClass("hide")
  $(`#mbs_menu_${membership.id}`).removeClass("hide")
}

let call_everlearn_api = () => {
  var settings = {
    "async": true,
    "crossDomain": true,
    "url": window.everlearn.api_url,
    "method": "POST",
    "headers": {
      "Content-Type": "application/json",
      "Authorization": 'Bearer ' + window.everlearn.token,
      "Cache-Control": "no-cache",
    },
    "processData": false,
    "data": JSON.stringify(window.everlearn.content)
  }

  $.ajax(settings).done(function (response) {
    if (response.api_answer_data != undefined){
      update_user_data(response.api_answer_data)
    }
    console.log("API called");
  }).fail(function(data){
    $("i.pb").removeClass("hide")
    $("i.ok, i.nok").addClass("hide")
    console.log(data)
  });
}
