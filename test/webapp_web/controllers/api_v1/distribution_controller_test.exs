defmodule WebappWeb.ApiV1.DistributionControllerTest do
  use WebappWeb.ConnCase

  alias Webapp.Distributions
  alias Webapp.Distributions.Distribution
  alias Webapp.Hypervisors

  @create_attrs %{
    image: "some image",
    loader: "some loader",
    name: "some name",
    version: "some version"
  }
  @update_attrs %{
    image: "some updated image",
    loader: "some updated loader",
    name: "some updated name",
    version: "some updated version"
  }
  #  @invalid_attrs %{image: nil, loader: nil, name: nil, version: nil}

  @webhook_token "1234567890"

  def fixture(:distribution) do
    {:ok, distribution} = Distributions.create_distribution(@create_attrs)
    distribution
  end

  def hypervisor_fixture do
    hypervisor_type = fixture_hypervisor_type(%{name: "bhyve"})
    region = fixture_region(%{name: "test region"})

    {:ok, _hypervisor} =
      Hypervisors.create_hypervisor(%{
        name: "authenticated-hypervisor",
        ip_address: "192.168.199.253",
        region_id: region.id,
        hypervisor_type_id: hypervisor_type.id,
        fqdn: "authenticated-hypervisor",
        webhook_token: @webhook_token
      })
  end

  defp authenticate(conn) do
    conn
    |> put_req_header("token", @webhook_token)
  end

  setup context do
    create_hypervisor()

    conn =
      if Map.has_key?(context, :authenticated_hypervisor) do
        authenticate(context.conn)
      else
        context.conn
      end

    conn = put_req_header(conn, "accept", "application/json")
    {:ok, conn: conn}
  end

  describe "index" do
    test "disallow listing distributions to unathenticated user/hypervisor", %{conn: conn} do
      conn = get(conn, Routes.distribution_path(conn, :index))
      assert response(conn, 401)
    end

    @tag :authenticated_hypervisor
    test "lists all distributions to authenticated user/hypervisor", %{conn: conn} do
      conn = get(conn, Routes.distribution_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create distribution" do
    test "disallow create distribution to unathenticated user/hypervisor", %{conn: conn} do
      conn = post(conn, Routes.distribution_path(conn, :create), distribution: @create_attrs)
      assert response(conn, 401)
    end
  end

  describe "update distribution" do
    setup [:create_distribution]

    test "renders distribution when data is valid", %{
      conn: conn,
      distribution: %Distribution{id: _id} = distribution
    } do
      conn =
        put(conn, Routes.distribution_path(conn, :update, distribution),
          distribution: @update_attrs
        )

      assert response(conn, 401)
    end
  end

  describe "delete distribution" do
    setup [:create_distribution]

    test "disallow delete chosen distribution to unauthenticated user/hypervisor", %{
      conn: conn,
      distribution: distribution
    } do
      conn = delete(conn, Routes.distribution_path(conn, :delete, distribution))
      assert response(conn, 401)
    end
  end

  defp create_distribution(_) do
    distribution = fixture(:distribution)
    {:ok, distribution: distribution}
  end

  defp create_hypervisor() do
    hypervisor = hypervisor_fixture()
    {:ok, hypervisor: hypervisor}
  end
end
