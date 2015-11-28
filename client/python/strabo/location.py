#
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

from strabo.strabo_object import StraboObject
import requests

class Location(StraboObject):
    def __init__(self, lat = None, lon = None):
        super(Location, self).__init__()
        self.lat = lat
        self.lon = lon

    def nearest_neighbors(self, location_set, n):
        return self.from_sexpr("nearest_neighbors", self, location_set, n)

    def nearest_neighbor(self, location_set):
        return self.from_sexpr("nearest_neighbor", self, location_set)

    def surrounding_polygons(self, shapefile_name):
        return self.from_sexpr("surrounding_polygons", self, shapefile_name)

    def sexpr(self):
        return ("location", self.lat, self.lon)

class LocationSet(StraboObject):
    """Represents a collection of locations."""
    value_type = Location

    def __init__(self, batch_id = None, filename = None, id_column = None,
                 lat_column = None, lon_column = None, **kwargs):
        """Initializes a LocationSet on the Strabo server.

        Arguments:
        batch_id   -- specifies an already existing location set on the Strabo
                      server. If left blank, then filename, id_column,
                      lat_column, and lon_column must be specified.
        filename   -- a string containing the filename of the CSV to upload
        id_column  -- the name of the column containing location (e.g. user)
                      ids in the CSV. Must be present in the first line (i.e.
                      the header) of the CSV.
        lat_column -- the name of the column containing latitude information
                      in the CSV. Must be present in the first line (i.e. the
                      header) of the CSV.
        lon_column -- the name of the column containing longitude information
                      in the CSV. Must be present in the first line (i.e. the
                      header) of the CSV.

        After upload is complete, stores the new batch_id of the uploaded CSV
        to self.batch_id. This dataset be referenced in the future with
        `LocationSet(batch_id = my_batch_id)`.
        """
        super(LocationSet, self).__init__(**kwargs)
        if batch_id is None:
            self._upload_csv(filename, id_column, lat_column, lon_column)
        else:
            self.batch_id = batch_id

    def _upload_csv(self, filename, id_column, lat_column, lon_column):
        params = {'id_column': id_column, 'lat_column': lat_column,
                  'lon_column': lon_column}
        with open(filename) as file_to_upload:
            response = requests.post(self.connection.strabo_url + "/location/batch",
                                     params=params,
                                     files={'upload': file_to_upload})
        response.raise_for_status()
        self.batch_id = response.json()['batch_id']

    def clear(self):
        return self.from_sexpr("clear_location_set", self)

    def sexpr(self):
        assert self.batch_id is not None
        return ("locations_from_batch", self.batch_id)
