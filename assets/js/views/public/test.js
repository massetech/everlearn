// import MainView from '../main';
//
// export default class View extends MainView {
//   mount() {
//     // ------- Initialization
//     super.mount()
//     console.log('PageTestView mounted')
//
//     $(document).ready(function () {
//       var swiper = new Swiper ('.swiper-container', {
//         direction: 'horizontal',
//         nextButton: '.swiper-button-next',
//         prevButton: '.swiper-button-prev',
//         loop: true
//       })
//       init_slides()
//       swiper.on('onSlideNextStart', function(){
//         console.log('slide next')
//         move_next_slide()
//       })
//     })
//     let data = window.Gon.getAsset('memberships')
//     sessionStorage.setItem("learnit-data", data)
//     let test = JSON.parse(sessionStorage.getItem("learnit-data"))
//     console.log(test)
//
//     // ------------- Jquery
//
//     let load_jquery_scripts = () => {
//       // Show answers on click
//       $(".show-btn").click(function() {
//         if($(this).parent().is(':visible')){
//           $(".swiper-slide-active").find(".question").hide()
//           $(".swiper-slide-active").find(".answer").show()
//           console.log("answers displayed")
//         }
//         console.log("clicked")
//       })
//     }
//
//     // $(".button").click(function() {
//     //   let new_item = choose_item(2, "0")
//     //   console.log(new_item)
//     // })
//
//     // ------------- Methods
//
//     let init_slides = () => {
//       load_item(3, "0", 0)
//       load_item(3, "0", 1)
//       load_item(3, "0", 2)
//       load_jquery_scripts()
//     }
//
//     let move_next_slide = () => {
//       move_right()
//       load_jquery_scripts()
//       raz_display()
//     }
//
//     let load_data = () => {
//       let data = JSON.parse(sessionStorage.getItem("learnit-data"))
//       return data
//     }
//     let get_list = (list_id) => {
//       let list = load_data().filter(m => m.list_id === list_id)[0]
//       //console.log(list)
//       return list
//     }
//     let get_items = (list_id, status) => {
//       let items = get_list(list_id).memorys.filter(m => m.status === status)
//       //console.log(items)
//       return items
//     }
//     // Choose random item in the list
//     let choose_item = (list_id, status) => {
//       let items = get_items(list_id, status)
//       let item = choose_random(items)
//       //console.log(item)
//       return item
//     }
//     let choose_random = (obj) => {
//       let keys = Object.keys(obj)
//       return obj[keys[ keys.length * Math.random() << 0]]
//     }
//     let load_item = (list_id, status, next_index) => {
//       let new_item = choose_item(list_id, status).item
//       console.log(new_item)
//       console.log(next_index)
//       $("[data-swiper-slide-index='" + next_index +"']").find(".dim").text(new_item.dim0)
//       $("[data-swiper-slide-index='" + next_index +"']").find(".dim0").text(new_item.dim0)
//       $("[data-swiper-slide-index='" + next_index +"']").find(".dim1").text(new_item.dim1)
//       $("[data-swiper-slide-index='" + next_index +"']").find(".dim2").text(new_item.dim2)
//       $("[data-swiper-slide-index='" + next_index +"']").find(".dim3").text(new_item.dim3)
//       $("[data-swiper-slide-index='" + next_index +"']").find(".dim4").text(new_item.dim4)
//       $("[data-swiper-slide-index='" + next_index +"']").find(".answer").hide()
//     }
//     // Move to the right (next)
//     let move_right = () => {
//       let slide_index = $(".swiper-slide-active").attr('data-swiper-slide-index')
//       let next_index
//       if(slide_index == 0) {next_index = 1}
//       if(slide_index == 1) {next_index = 2}
//       if(slide_index == 2) {next_index = 0}
//       load_item(3, "0", next_index)
//     }
//     // Move to the left (back)
//     let move_left = (card_id) => { // See later what to do :)
//     }
//     // RAZ du display
//     let raz_display = () => {
//       $(".swiper-slide").find(".question").show()
//       $(".swiper-slide").find(".answer").hide()
//     }
//
//     let move_item = (list_id, status, id, movement) => {
//       let new_status
//       if(movement === "UP") {
//         new_status = "status3"
//         if(status == "status0") {new_status = "status1"}
//         if(status == "status1") {new_status = "status2"}
//       } else if(movement === "DOWN") {
//         new_status = "status0"
//         if(status == "status3") {new_status = "status2"}
//         if(status == "status2") {new_status = "status1"}
//       } else {
//         // Place item in quarantine
//         new_status = "passed"
//       }
//       let item = get_item(list_id, status, id)
//       //console.log(new_status)
//       data.lists.filter(list => list.id == list_id)[0][new_status].push(item)
//       rem_item(list_id, status, id)
//     }
//     // Remove item by id
//     // let remove_item = (list_id, status, id) => {
//     //   let index = get_items(list_id, status).findIndex(item => item.id == id)
//     //   console.log(index)
//     //   let data = load_data()
//     //   .splice(index, 1)
//     // }
//
//
//
//
//   }
//
//   unmount() {
//     super.unmount()
//     console.log('PageTestView unmounted')
//     sessionStorage.removeItem('learnit-data');
//
//
//   }
// }
