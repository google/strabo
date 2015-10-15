/home/vagrant/bin:
  file.directory:
    - user: vagrant
    - group: vagrant
    - mode: 700

{% set commands = [
  ('start_server',   'mix deps.get; mix phoenix.server'),
  ('run_tests',      'mix deps.get; mix test'),
  ('run_migrations', 'mix deps.get; mix ecto.migrate'),
] %}

{% for (name, command) in commands %}
/home/vagrant/bin/{{ name }}:
  file.managed:
    - user: vagrant
    - group: vagrant
    - mode: 700
    - contents: |
        #!/bin/bash
        cd /vagrant
        {{ command }}
{% endfor %}

/etc/motd:
  file.managed:
    - contents: |
        ================================================================================

        Developer commands include:

         start_server   - Start the Phoenix server
         run_migrations - Run schema migrations
         run_tests      - Run tests

        ================================================================================

/etc/update-motd.d/10-help-text:
  file.absent

/etc/update-motd.d/50-landscape-sysinfo:
  file.absent

/etc/update-motd.d/51-cloudguest:
  file.absent
