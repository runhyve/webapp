defmodule Webapp.BhyveTest do
  use Webapp.DataCase

  alias Webapp.Hypervisors.Bhyve

  setup do
    bypass = Bypass.open()

    hypervisor_type = fixture_hypervisor_type(%{name: "bhyve"})
    region = fixture_region(%{name: "test region"})

    hypervisor =
      fixture_hypervisor(%{
        name: "test_hypervisor_2",
        ip_address: "127.0.0.1",
        region_id: region.id,
        hypervisor_type_id: hypervisor_type.id,
        fqdn: "localhost:#{bypass.port}",
        webhook_token: "Eus3oghas3loo0nietur1eighao5ciay",
        tls: false,
      })

    {:ok, bypass: bypass, hypervisor: hypervisor}
  end

  test "request are performed with valid token header", %{hypervisor: hypervisor, bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      assert Plug.Conn.get_req_header(conn, "x-runhyve-token") == [hypervisor.webhook_token]
      Plug.Conn.resp(conn, 200, ~s<{"status":"success","message":"healthy"}>)
    end)

    assert {:ok, "healthy"} = Bhyve.hypervisor_status(hypervisor)
  end

  test "backend can handle 403 response", %{hypervisor: hypervisor, bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 403, "403 Forbidden")
    end)

    assert {:error, "403 Forbidden"} = Bhyve.hypervisor_status(hypervisor)
  end

  test "backend can handle 404 response", %{hypervisor: hypervisor, bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 404, "Hook not found.")
    end)

    assert {:error, "Hook not found."} = Bhyve.hypervisor_os_details(hypervisor)
  end

  test "backend can handle invalid JSON response", %{hypervisor: hypervisor, bypass: bypass} do
    invalid_json = ~s<{"status":"error" "message":"Virtual machine test doesn't exist"}>
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 403, invalid_json)
    end)

    assert {:error, invalid_json} = Bhyve.hypervisor_status(hypervisor)
  end

  test "backend can handle error response", %{hypervisor: hypervisor, bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, ~s<{"status":"error","message":"Virtual machine test doesn't exist"}>)
    end)

    assert {:error, "Virtual machine test doesn't exist"} = Bhyve.hypervisor_status(hypervisor)
  end

  test "request with unexpected outage", %{hypervisor: hypervisor, bypass: bypass} do
    Bypass.down(bypass)
    assert {:error, :econnrefused} = Bhyve.job_status(nil, nil, hypervisor, 10)
  end

  test "request with invalid hypervisor fqdn", %{hypervisor: hypervisor} do
    hypervisor = hypervisor
                 |> Map.replace!(:fqdn, "this.host.does.not.exists.runhyve")
    assert {:error, :nxdomain} = Bhyve.hypervisor_status(hypervisor)
  end

end