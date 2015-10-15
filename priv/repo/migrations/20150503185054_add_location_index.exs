# Copyright 2015 Google, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

defmodule Strabo.Repo.Migrations.AddLocationIndex do
  use Ecto.Migration

  def up do
    execute "CREATE INDEX locations_gix ON locations USING GIST (geom);"
    execute "CREATE INDEX uid_idx ON locations (uid);"
    execute "CREATE INDEX ts_idx ON locations (ts);"
  end

  def down do 
    execute "DROP INDEX locations_gix;"
    execute "DROP INDEX uid_idx;"
    execute "DROP INDEX ts_idx;"
  end
end
