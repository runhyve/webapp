defmodule Webapp.HypervisorCase do
  use ExUnit.CaseTemplate
  alias Webapp.Repo

  import Webapp.TestHelpers

  setup_all _tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Webapp.Repo)
    # we are setting :auto here so that the data persists for all tests,
    # normally (with :shared mode) every process runs in a transaction
    # and rolls back when it exits. setup_all runs in a distinct process
    # from each test so the data doesn't exist for each test.
    Ecto.Adapters.SQL.Sandbox.mode(Webapp.Repo, :auto)
    hypervisor_type = fixture_hypervisor_type(%{name: "bhyve"})
    region = fixture_region(%{name: "fake region"})

    hypervisor =
      fixture_hypervisor(%{
        name: "test_hypervisor_1",
        ip_address: "192.168.199.254",
        hypervisor_type_id: hypervisor_type.id,
        region_id: region.id,
        fqdn: "http://192.168.199.254.xip.io",
        webhook_token: "Eus3oghas3loo0nietur1eighao5ciay",
        tls: false,
      })

    network = fixture_network(%{
      name: "test_network_1",
      network: "0.0.0.0/32",
      hypervisor_id: hypervisor.id
    })

    on_exit fn ->
      # this callback needs to checkout its own connection since it
      # runs in its own process
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Webapp.Repo)
      Ecto.Adapters.SQL.Sandbox.mode(Webapp.Repo, :auto)

      Webapp.Networks.delete_network(network)
      Webapp.Hypervisors.delete_hypervisor(hypervisor)
      Repo.delete(hypervisor_type)
      Repo.delete(region)
      :ok
    end

    [hypervisor: hypervisor, network: network]
  end
end
