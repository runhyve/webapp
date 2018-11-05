defmodule WebappWeb.PlanController do
  use WebappWeb, :controller

  alias Webapp.Plans
  alias Webapp.Plans.Plan

  def index(conn, _params) do
    plans = Plans.list_plans()

    chargebee_api_endpoint = "https://serveraptor-test.chargebee.com/api/v2"
    chargebee_api_key = "test_2mbCHBYhb1Mk7DK8VD8VPMre7PrfpNVI"

    %{status_code: status_code, body: response} = HTTPoison.get!(chargebee_api_endpoint <> "/plans/", [], [hackney: [basic_auth: {chargebee_api_key, ""}]])
    %{"list" => chargebee_plans} = Jason.decode!(response)

    chargebee_plans = Enum.map(chargebee_plans, fn %{"plan" => plan} -> plan end)
    IO.inspect(chargebee_plans)

    render(conn, "index.html", plans: plans, chargebee_plans: chargebee_plans)
  end

  def new(conn, _params) do
    changeset = Plans.change_plan(%Plan{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"plan" => plan_params}) do
    case Plans.create_plan(plan_params) do
      {:ok, plan} ->
        conn
        |> put_flash(:info, "Plan created successfully.")
        |> redirect(to: Routes.plan_path(conn, :show, plan))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    plan = Plans.get_plan!(id)
    render(conn, "show.html", plan: plan)
  end

  def edit(conn, %{"id" => id}) do
    plan = Plans.get_plan!(id)
    changeset = Plans.change_plan(plan)
    render(conn, "edit.html", plan: plan, changeset: changeset)
  end

  def update(conn, %{"id" => id, "plan" => plan_params}) do
    plan = Plans.get_plan!(id)

    case Plans.update_plan(plan, plan_params) do
      {:ok, plan} ->
        conn
        |> put_flash(:info, "Plan updated successfully.")
        |> redirect(to: Routes.plan_path(conn, :show, plan))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", plan: plan, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    plan = Plans.get_plan!(id)
    {:ok, _plan} = Plans.delete_plan(plan)

    conn
    |> put_flash(:info, "Plan deleted successfully.")
    |> redirect(to: Routes.plan_path(conn, :index))
  end
end
