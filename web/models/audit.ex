defmodule BacklogCleaner.Audit do
  use BacklogCleaner.Web, :model

  @keep_open_action "keep"
  @close_action "close"

  schema "audits" do
    field :repo_owner, :string
    field :repo_name, :string
    field :issue_number, :integer
    field :action, :string

    belongs_to :user, BacklogCleaner.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :repo_name, :repo_owner, :issue_number, :action])
    |> validate_required([:user_id, :repo_name, :repo_owner, :issue_number, :action])
    |> update_change(:action, &String.downcase/1)
    |> validate_format(:action, ~r/close|keep/)
  end

  def for_repo(query, repo_owner, repo_name) do
    from audit in query,
    where: audit.repo_owner == ^repo_owner and
           audit.repo_name == ^repo_name 
  end

  def for_issue(query, issue_number) do
    from a in query,
      where: a.issue_number == ^issue_number
  end

  def with_user(query) do
    from audit in query, preload: [:user]
  end

  def most_recent(query) do
    (from a in query, order_by: [desc: a.inserted_at])
    |> first
  end

  def audited_issues(query) do
    from audit in query,
    distinct: audit.issue_number,
    select: audit.issue_number
  end

  def issues_to_keep(query) do
    from audit in query,
    where: audit.action == @keep_open_action
  end

  def keep_changeset(user, repo_owner, repo_name, issue_number) do
    base_changeset(user, repo_owner, repo_name, issue_number, @keep_open_action)
  end

  def close_changeset(user, repo_owner, repo_name, issue_number) do
    base_changeset(user, repo_owner, repo_name, issue_number, @close_action)
  end

  defp base_changeset(user, repo_owner, repo_name, issue_number, action, model \\ %BacklogCleaner.Audit{}) do
    changeset(
      model,
      %{
        user_id: user.id,
        repo_owner: repo_owner,
        repo_name: repo_name,
        issue_number: issue_number,
        action: action
      }
    )
  end
end
