defmodule EverlearnWeb.PackCommander do
  use Drab.Commander
  alias Everlearn.Contents
  onload :page_loaded

  def page_loaded(socket) do
    socket |> exec_js("console.log('Alert from the other side!');")
  end

  def toogle_pack(socket, payload) do
    %{"itemId" => item_id, "packId" => pack_id} = payload["dataset"]
    case Everlearn.Contents.toogle_pack_item(item_id, pack_id) do
      {:created, pack_item} ->
        socket
        |> Drab.Browser.console("PackItem created for item #{item_id} and pack #{pack_id}")
        |> set_prop(".item[id='#{item_id}']", %{"attributes" => %{"class" => "item waves-effect waves-light btn validate"}})
      {:deleted, pack_item} ->
        socket
        |> Drab.Browser.console("PackItem removed for item #{item_id} and pack #{pack_id}")
        |> set_prop(".item[id='#{item_id}']", %{"attributes" => %{"class" => "item waves-effect waves-light btn light"}})
      {:error, _} ->
        socket
        |> Drab.Browser.console("Couldn't create PackItem between item #{item_id} and pack #{pack_id}")
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
