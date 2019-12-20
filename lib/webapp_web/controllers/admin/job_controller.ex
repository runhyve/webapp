defmodule WebappWeb.Admin.JobController do
  use WebappWeb, :controller

  alias Webapp.Jobs
  alias Webapp.Jobs.Job

  plug :load_and_authorize_resource,
       model: Job,
       non_id_actions: [:index],
       preload: [:hypervisor]

  def index(conn, _params) do
    job = Jobs.list_jobs()
    render(conn, "index.html", job: job)
  end
end
