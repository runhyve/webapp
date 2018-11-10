# Tools for developers and admins

## Machine

To add existing machine on hypervisor to webapp run:
```
mix run tools/machine.exs add --plan 3 --hypervisor 1 --name addtest --template ubuntu
```

To change `created` flag on machine run:.
```
mix run tools/machine.exs update --machine 54 --created true
```