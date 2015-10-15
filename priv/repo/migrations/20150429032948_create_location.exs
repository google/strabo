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

defmodule Strabo.Repo.Migrations.CreateLocation do
  use Ecto.Migration

  def up do
		execute "CREATE TABLE IF NOT EXISTS locations (uid varchar(255), lat float, lon float, geom geometry(Point, 4326), metadata json, ts timestamp without time zone default (now() at time zone 'utc'));"
  end

	def down do
		execute "DROP TABLE locations;"
	end
end
