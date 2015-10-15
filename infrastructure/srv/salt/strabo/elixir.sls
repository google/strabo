elixir:
  pkgrepo.managed:
    - humanname: Erlang Solutions PPA
    - name: deb http://packages.erlang-solutions.com/ubuntu trusty contrib
    - dist: trusty
    - require_in:
      - pkg: elixir

  pkg.latest:
    - name: elixir
    - refresh: True
    - skip_verify: True