defmodule EverlearnWeb.ItemCommander do
  use Drab.Commander
  alias Everlearn.{Contents, Members, CustomMethods}

  def delete_card_alert(socket, payload) do
    %{"cardId" => card_id} = payload["dataset"]
    Members.delete_memory_alert_for_card_id(card_id)
    socket
      |> set_prop("a[id='card_alert_#{card_id}']", %{"attributes" => %{"class" => "hide"}})
    socket
      |> Drab.Browser.console("Alerts were removed for Card #{card_id}")
  end
end
