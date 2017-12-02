defmodule Everlearn.Auth.Guardian do
  use Guardian, otp_app: :everlearn
  alias AuthEx.Auth

  # Returns something that can identify our user
  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  # Extract an id from the claims of JWT, then return the matching user
  def resource_from_claims(claims) do
    {:ok, %{id: claims["sub"]}}
    # user = claims["sub"]
    # |> Auth.get_user!
    # {:ok, user}
  end
end
