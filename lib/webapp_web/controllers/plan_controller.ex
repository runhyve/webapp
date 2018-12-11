defmodule WebappWeb.PlanController do
  use WebappWeb, :controller

  alias Webapp.Plans
  alias Webapp.Plans.Plan

  plug :is_admin?

  def index(conn, _params) do
    plans = Plans.list_plans()
    render(conn, "index.html", plans: plans)
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
