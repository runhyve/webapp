# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Webapp.Repo.insert!(%Webapp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Webapp.Repo.insert!(%Webapp.Hypervisors.Type{name: "bhyve"})

# Test dummy data
Webapp.Repo.insert!(%Webapp.Plans.Plan{name: "1C-512MB-10HDD", ram: 512, storage: 10, cpu: 1})
Webapp.Repo.insert!(%Webapp.Plans.Plan{name: "1C-1024MB-50HDD", ram: 1024, storage: 50, cpu: 1})
Webapp.Repo.insert!(%Webapp.Plans.Plan{name: "2C-2048MB-100HDD", ram: 2048, storage: 100, cpu: 2})
