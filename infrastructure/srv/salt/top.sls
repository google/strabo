{% set roles = salt['grains.get']('roles', '') %}

base:
  'environment:vagrant':
    - match: grain
    - strabo.development
    - strabo.elixir
    - strabo.axel

{% for role in roles %}
  'roles:{{ role }}':
    - match: grain
    - strabo.{{ role }}
{% endfor %}
