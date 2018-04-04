defmodule EverlearnWeb.PackCommander do
  use Drab.Commander
  alias Everlearn.{Contents, Members, CustomMethods}
  # onload :page_loaded

  # def page_loaded(socket) do
  #   socket |> exec_js("console.log('Alert from the other side!');")
  # end

  def toogle_item_pack(socket, payload) do
    %{"itemId" => item_id, "packId" => pack_id} = payload["dataset"]
    case Contents.toogle_pack_item(item_id, pack_id) do
      {:created, _pack_item} ->
        socket
          |> Drab.Browser.console("PackItem created for item #{item_id} and pack #{pack_id}")
        socket
          |> set_attr(".item-card[id='#{item_id}']", class: "card item-card selected")
        # socket
        #   |> set_prop("a.item[id='#{item_id}']", innerHTML: "Remove")
        # socket
        #   |> insert_html("a.item[id='#{item_id}']", :beforeend, "<i class='toogle_btn material-icons left'>remove_circle_outline</i>")
      {:deleted, _pack_item} ->
        socket
          |> Drab.Browser.console("PackItem removed for item #{item_id} and pack #{pack_id}")
        socket
          |> set_attr(".item-card[id='#{item_id}']", class: "card item-card")
        socket
        #   |> set_prop("a.item[id='#{item_id}']", innerHTML: "Add")
        # socket
        #   |> insert_html("a.item[id='#{item_id}']", :beforeend, "<i class='toogle_btn material-icons left'>add_circle_outline</i>")
      {:error, _} ->
        socket
          |> Drab.Browser.console("Couldn't create PackItem between item #{item_id} and pack #{pack_id}")
    end
  end

  def toogle_pack_language(socket, payload) do
    %{"languageId" => language_id, "packId" => pack_id} = payload["dataset"]
    %{"title" => title} = payload["form"]
    # Empty title field
    socket
      |> set_prop("input[id='title", value: "")
    case Contents.toogle_packlanguage(language_id, pack_id, title) do
      {:created, pack_language} ->
        socket
          |> Drab.Browser.console("PackLanguage created for language #{language_id} and pack #{pack_id}")
        socket
          |> set_prop("i[id='icon_language_#{language_id}']", innerHTML: "star")
        socket
          |> set_prop("span[id='span_#{language_id}']", innerHTML: "Title : #{pack_language.title}")
      {:deleted, _pack_language} ->
        socket
          |> Drab.Browser.console("PackLanguage created for language #{language_id} and pack #{pack_id}")
        socket
          |> set_prop("i[id='icon_language_#{language_id}']", innerHTML: "star_border")
        socket
          |> set_prop("span[id='span_#{language_id}']", innerHTML: "Title : ")
      {:error, changeset} ->
        msg = CustomMethods.get_first_error(changeset.errors)
        socket
          |> Drab.Browser.console("Couldn't create PackLanguage between language #{language_id} and pack #{pack_id} : #{msg}")
    end
  end

  def toogle_membership(socket, payload) do
    %{"studentLgId" => student_lg_id, "teacherLgId" => teacher_lg_id, "packId" => pack_id, "userId" => user_id} = payload["dataset"]
    # IO.inspect(payload["dataset"])
    case Members.toogle_membership(user_id, student_lg_id, teacher_lg_id, pack_id) do
      {:created, msg} ->
        socket
          |> Drab.Browser.console("Membership created for user #{user_id} and pack #{pack_id}, #{msg}")
        socket
          |> set_prop("[id='pack_#{pack_id}']", %{"attributes" => %{"class" => "selected"}})
        # socket
        #   |> set_prop("a[id='a_#{pack_id}']", innerHTML: "Stop learning")
        # socket
        #   |> insert_html("a[id='a_#{pack_id}']", :beforeend, "<i class='material-icons left'>cloud_off</i>")
      {:deleted, msg} ->
        socket
          |> Drab.Browser.console("Membership removed for user #{user_id} and pack #{pack_id}, #{msg}")
        socket
          |> set_prop("[id='pack_#{pack_id}']", %{"attributes" => %{"class" => "selected hide"}})
        # socket
        #   |> set_prop("a[id='a_#{pack_id}']", innerHTML: "Learn it")
        # socket
        #   |> insert_html("a[id='a_#{pack_id}']", :beforeend, "<i class='material-icons left'>cloud_download</i>")
      {_, msg} ->
        socket
          |> Drab.Browser.console("Couldn't create Membership between user #{user_id} and pack #{pack_id}")
        socket
          |> Drab.Browser.console(msg)
    end
  end

  # Drab Callbacks
  # def page_loaded(socket) do
  #   #poke socket, welcome_text: "Coucou thibs"
  #   # set_prop socket, "div.jumbotron p.lead",
  #   #   innerHTML: "Please visit <a href='https://tg.pl/drab'>Drab</a> page for more"
  # end

  # def uppercase(socket, sender) do
  #   text = sender.params["text_to_uppercase"]
  #   poke socket, text: String.upcase(text)
  # end
  #
  # def lowercase(socket, sender) do
  #   text = sender.params["text_to_uppercase"]
  #   poke socket, text: String.downcase(text)
  # end

  # def clicked(socket, payload) do
  #   #socket |> Drab.Browser.console("You've sent me this: #{payload |> inspect}")
  #   IO.puts("++++++++")
  #   # IO.puts("test ok !")
  #   # IO.puts("++++++++")
  # end

  # def clicked(socket, payload) do
  #   IO.puts("++++++++")
  #   IO.puts("button clicked ok !")
  #   IO.puts("++++++++")
  #   socket |> Drab.Browser.console("You've sent me this: #{payload |> inspect}")
  # end
  #
  # def button_clicked(socket, payload) do
  #   #socket |> Drab.Browser.console("You've sent me this: #{payload |> inspect}")
  #   content = peek(socket, :button)
  #   IO.puts("++++++++")
  #   IO.puts(content)
  #   IO.puts("++++++++")
  #   poke(socket, button: "test ok man !")
  # end

  # def button_clicked(socket, sender) do
  #   set_prop socket, "#output_div", innerHTML: "Clicked the button!"
  # end
end
