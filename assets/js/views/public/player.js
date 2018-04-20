import MainView from '../main'

export default class View extends MainView {
  mount() {
    super.mount()
    console.log('PublicPlayerView mounted')

    init_user_data()
    init_slidebars()
    init_slidebar_functions()
    init_caroussel()
    init_action_btns()
  }

  unmount() {
    super.unmount()
    console.log('PublicPlayerView unmounted')
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
  // console.log(action)
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
  $('.carousel').carousel('next')
}

let calculate_slide_number = (id) => {
  let new_slide_id = id
  let next_slide_id = (id + 1)%3
  return [new_slide_id, next_slide_id]
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
  // Update slide ID in carousel
  $(`#slide_${id}`).find('.asked').text(new_question)
  $(`#slide_${id}`).find('.card_question').text(`${new_card.question}`)
  $(`#slide_${id}`).find('.card_answer').text(`${new_card.answer}`)
  $(`#slide_${id}`).find('.card_phonetic').text(`${new_card.phonetic}`)
  // Reinitialize Hide&Show in slides
  $(`.carousel-item`).find('.question').removeClass(`hide`)
  $(`.carousel-item`).find('.answer').addClass(`hide`)
  console.log(`New card ${new_card.id} with status${new_card.status} updated on slide ${id}`)
}

let show_slide_answer = (slide_id) => {
  $(`#${slide_id}.carousel-item`).find('.question').addClass(`hide`)
  $(`#${slide_id}.carousel-item`).find('.answer').removeClass(`hide`)
}

let update_cards_in_carousel = (new_slide_id) => {
  let learning_mode = window.everlearn.learning_mode
  let card_list = window.everlearn.card_list
  let ids = calculate_slide_number(new_slide_id)
  update_slide(ids[0])
  update_slide(ids[1])
  update_progress_share()
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

let update_with_slidebar1_change = (classroom_id, membership_id) => {
  let classroom = window.everlearn.content.classrooms.find(x => x.id == classroom_id)
  let membership = classroom.memberships.find(x => x.id == membership_id)
  window.everlearn.classroom = classroom.id
  window.everlearn.membership = membership.id
  window.everlearn.learning_mode = "question_or_answer"
  window.everlearn.card_list = membership.cards
  $(`#classroom_title`).text(`${classroom.title}`)
  $(`#membership_title`).text(`${membership.title}`)
  update_cards_in_carousel(0)
  update_cards_in_carousel(1)
  update_cards_in_carousel(2)
  console.log("Classroom or membership updated")
}

// ------------- Initialization  -----------------------------------------------------------------
let init_user_data = () => {
  var data = JSON.parse(window.Gon.assets().json_data)
  window.everlearn = []
  window.everlearn.token = data.token
  update_user_data(data.content)
}
let update_user_data = (content) => {
  window.everlearn.content = content
  var first_classroom_id = window.everlearn.content.classrooms[0].id || 0
  var first_membership_id = window.everlearn.content.classrooms[0].memberships[0].id || 0
  update_with_slidebar1_change(first_classroom_id, first_membership_id)
}

let init_action_btns = () => {
  $("#btn-renew").on('touchstart click', function() {
    event.stopPropagation()
    event.preventDefault()
    update_card_status('renew')
  })
  $("#btn-cancel").on('touchstart click', function() {
    event.stopPropagation()
    event.preventDefault()
    update_card_status('cancel')
  })
  $("#btn-known").on('touchstart click', function() {
    event.stopPropagation()
    event.preventDefault()
    update_card_status('up')
  })
  $("#call-api").on('touchstart click', function() {
    event.stopPropagation()
    event.preventDefault()
    call_api(window.everlearn.token)
    slidebars_controller.toggle('slidebar2')
  })
}

let init_slidebars = () => {
  document.getElementById(`membership_${window.everlearn.membership}`).classList.remove("hide")
  $("#btn-school").on('touchstart click', function() {
    event.stopPropagation()
    event.preventDefault()
    slidebars_controller.toggle('slidebar1')
  })
  $("#btn-settings").on('touchstart click', function() {
    event.stopPropagation()
    event.preventDefault()
    slidebars_controller.toggle('slidebar2')
  })
  console.log("slidebar js initialized")
}

let init_caroussel = () => {
  update_cards_in_carousel()
  $('.carousel.carousel-slider').carousel({
    duration: 100,
    onCycleTo: function(element, dragged) {
      // console.log($(element).index())
      update_cards_in_carousel($(element).index())
    }
  })
  $("#move_previous").on('touchstart click', function() {
    $('.carousel').carousel('prev')
  })
  $("#move_next").on('touchstart click', function() {
    $('.carousel').carousel('next')
  })
  $(".carousel-item").on('touchstart click', function() {
    show_slide_answer(this.id)
  })
}

let init_slidebar_functions = () => {
  $(".sidebar1_btn").on('touchstart click', function() {
    console.log("slidebar1 triggered")
    update_with_slidebar1_change(this.dataset.classroom_id, this.dataset.membership_id)
    event.stopPropagation()
    event.preventDefault()
    slidebars_controller.toggle('slidebar1')
  })
  $(".sidebar2_btn").on('touchstart click', function() {
    console.log("slidebar2 triggered")
    $('.carousel').carousel('next')
    window.everlearn.learning_mode = this.dataset.learning_mode
    event.stopPropagation()
    event.preventDefault()
    slidebars_controller.toggle('slidebar2')
  })
}

let call_api = (token) => {
  // var rok_url = 'http://21102b02.ngrok.io'
  // var api_url = rok_url + '/api/v1'
  var url = 'https://angry-quintessential-needletail.gigalixirapp.com/'
  var api_url = url + '/api/v1'
  var autorization = 'Bearer ' + token
  // console.log(window.everlearn.content)
  var data = JSON.stringify(window.everlearn.content)
  // console.log(data)
  $.ajax({
    url: api_url,
    method: 'POST',
    contentType: 'application/json',
    headers: {"Authorization": autorization},
    data: data,
    success: function(response) {
      //(this.readyState == 4 && this.status == 200)
      if (response.api_data != undefined){
        console.log(response)
        update_user_data(response.api_data)
      }
    },
    error: function(response) {
      console.log('error : ' + response)
    }
  })
}
