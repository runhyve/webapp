defmodule Webapp.Chargebee.Plan do

  alias Webapp.{
    Chargebee.Customer,
    Chargebee.Request
  }

  def cb_active?() do
    Application.get_env(:webapp, Webapp.Chargebee)[:enable]
  end

  def cb_list_plans() do
    {:ok, %{"list" => plans}} = Request.get("plans")
    Enum.map(plans, fn %{"plan" => plan} -> plan end)
  end

  def cb_get_plan(id) do
    Request.get("plans/#{id}")
  end

  def cb_add_plan(plan_params) do
    plan = %{
      "id" => "#{plan_params["name"]}-#{plan_params["period_unit"]}ly",
      "name" => plan_params["name"],
      "price" => plan_params["price"],
      "currency_code" => plan_params["currency_code"], # TODO: chargebee only allow currencies that are enabled
      "period_unit" => plan_params["period_unit"]
    } 

    Request.post("plans", plan)
  end
end