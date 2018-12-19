defmodule Webapp.Types.UserRole do
  @moduledoc """
  This module introduces a custom type for Etco for checking user role in the user model
  """
  use Webapp.Types.EnumTypes

  def type, do: :user_role
  def valid_types, do: ["Administrator", "User"]
end
