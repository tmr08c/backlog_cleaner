defmodule BacklogCleaner.User do
  use BacklogCleaner.Web, :model

  schema "users" do
    field :email, :string
    field :username, :string
    field :name, :string
    field :avatar_url, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :username, :name, :avatar_url])
    |> validate_required([:email, :username, :name])
  end

  def with_email(email) do
    from u in __MODULE__, where: u.email == ^email
  end
end
