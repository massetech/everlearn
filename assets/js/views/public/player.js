import MainView from '../main'

export default class View extends MainView {
  mount() {
    super.mount()
    // console.log('PublicPlayerView mounted')
    init_player_data()
    init_slidebar_functions()
    init_slides()
    init_action_btns()
  }

  unmount() {
    super.unmount()
    // console.log('PublicPlayerView unmounted')
  }
}

// ------------- Methods  -----------------------------------------------------------------
let update_card_status = (action) => {
  let card_id = window.everlearn.actual_card
  let card_list = window.everlearn.card_list
  let updated_index = window.everlearn.card_list.findIndex(x => x.id == card_id)
  let updated_card = window.everlearn.card_list[updated_index]
  if (action == "up" && updated_card.nb_practice > 5 && updated_card.status >= 2) {action = "known"}
  else if (action == "up" && updated_card.status == -1) {action = "renew"}
  else if (action == "up") {action = "half-known"}
  const cases = {
    "renew": 1,
    "cancel": -1,
    "half-known": 2,
    "known": 3
  }
  updated_card.status = cases[action]
  updated_card.nb_practice = updated_card.nb_practice +1
  window.everlearn.card_list[updated_index] = updated_card
  console.log(`action has been done : ${action} : new card status ${window.everlearn.card_list[updated_index].status}`)
  update_slides()
}

let show_slides_answer = () => {
  $(`.slides-item`).find('.question').fadeOut(800).addClass(`hide`)
  $(`.slides-item`).find('.answer').fadeIn(800).removeClass(`hide`)
}

let show_slides_question = () => {
  $(`.slides-item`).find('.answer').fadeOut(800).addClass(`hide`)
  $(`.slides-item`).find('.question').fadeIn(800).removeClass(`hide`)
}

let update_slides = () => {
  var actual_slide_id = $(`.slides`).find('.slides-item .active').attr('id') || 'slide_2'
  var new_slide_id = calculate_new_slide_item(actual_slide_id)
  $(`.slides`).find('.slides-item').addClass(`hide`).removeClass(`active`)
  $(`.slides`).find('.slides-item').addClass(`hide`)
  update_slide(new_slide_id)
  show_slides_question()
  $(`#${new_slide_id}.slides-item`).removeClass(`hide`).addClass(`active`)
  update_progress_share()
}

let calculate_new_slide_item = (actual_slide_id) => {
  var actual_id = parseInt(actual_slide_id[actual_slide_id.length -1])
  var next_id = (actual_id + 1)%3
  return `slide_${next_id}`
}

let update_slide = (id) => {
  // Load datas
  let learning_mode = window.everlearn.learning_mode
  let card_list = window.everlearn.card_list
  // Load new question
  let new_card = choose_random(card_list)
  window.everlearn.actual_card = new_card.id
  const cases = {
    "question_or_answer": new_card[choose_random([`question`, `answer`])],
    "question": new_card.question,
    "answer": new_card.answer,
    "sound": new_card.sound
  }
  var new_question = cases[learning_mode]
  $(`#${id}`).find('.asked').text(new_question)
  $(`#${id}`).find('.card_question').text(`${new_card.question}`)
  $(`#${id}`).find('.card_answer').text(`${new_card.answer}`)
  $(`#${id}`).find('.card_phonetic').text(`${new_card.phonetic}`)
  console.log(`New card ${new_card.id} with status${new_card.status} updated on ${id}`)
}

let update_progress_share = () => {
  var total = window.everlearn.card_list.length
  var level1_share = window.everlearn.card_list.filter(card => card.status == 1).length / total * 100
  var level2_share = window.everlearn.card_list.filter(card => card.status == 2).length / total * 100
  var level3_share = window.everlearn.card_list.filter(card => card.status == 3).length / total * 100
  var levelminus1_share = window.everlearn.card_list.filter(card => card.status == -1).length / total * 100
  var level0_share = 100 - level1_share - level2_share - level3_share - levelminus1_share
  // console.log([level0_share, level1_share, level2_share, level3_share])
  // console.log("level0_share : " + level0_share + ", level1_share : " + level1_share + ", level2_share : " + level2_share)
  $("#level0_share").css('width', level0_share + '%')
  $("#level1_share").css('width', level1_share + '%')
  $("#level2_share").css('width', level2_share + '%')
  $("#level3_share").css('width', level3_share + '%')
  $("#levelminus1_share").css('width', levelminus1_share + '%')
}

let list_change = (classroom_id, membership_id) => {
  let classroom = window.everlearn.content.classrooms.find(x => x.id == classroom_id)
  let membership = classroom.memberships.find(x => x.id == membership_id)
  window.everlearn.classroom = classroom.id
  window.everlearn.membership = membership.id
  window.everlearn.learning_mode = "question_or_answer"
  window.everlearn.card_list = membership.cards
  $(`#classroom_title`).text(`${classroom.title}`)
  $(`#membership_title`).text(`${membership.title}`)
  update_slides()
}

// ------------- Initialization  -----------------------------------------------------------------
let init_player_data = () => {
  var data = JSON.parse(window.Gon.assets().json_data)
  window.everlearn = []
  window.everlearn.token = data.token
  window.everlearn.api_url = window.Gon.assets().api_url
  update_user_data(data.content)
}

let update_user_data = (content) => {
  window.everlearn.content = content
  var first_classroom_id = window.everlearn.content.classrooms[0].id || 0
  var first_membership_id = window.everlearn.content.classrooms[0].memberships[0].id || 0
  list_change(first_classroom_id, first_membership_id)
}

let init_action_btns = () => {
  $("#btn-renew").on('touchstart click', function() {
    update_card_status('renew')
    event.stopPropagation()
    event.preventDefault()
  })
  $("#btn-cancel").on('touchstart click', function() {
    update_card_status('cancel')
    event.stopPropagation()
    event.preventDefault()
  })
  $("#btn-known").on('touchstart click', function() {
    update_card_status('up')
    event.stopPropagation()
    event.preventDefault()
  })
}

let init_slides = () => {
  // console.log("ici c normal")
  // update_slides()
  $(".slides-item").on('touchstart click', function() {
    // show_slides_answer(this.id)
    show_slides_answer()
  })
}

let init_slidebar_functions = () => {
  $(".toogle_mbs_change").on('touchstart click', function() {
    // console.log("slidebar left triggered")
    list_change(this.dataset.classroom_id, this.dataset.membership_id)
  })
  $(".toogle_interrogation_change").on('touchstart click', function() {
    // console.log("slidebar right triggered")
    window.everlearn.learning_mode = this.dataset.learning_mode
    update_slides()
  })
  $(".toogle_api").on('touchstart click', function() {
    call_everlearn_api()
  })
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
    console.log(response);
  });
}
