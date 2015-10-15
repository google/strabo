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

from strabo.connection import StraboConnection

def arg_from_type(strabo_type):
    patched_object = strabo_type()
    patched_object.sexpr = lambda: ("arg",)
    return patched_object

class StraboObject(object):
    value_type = None
    _sexpr = None

    def __init__(self, connection = None):
        if connection is None:
            self.connection = StraboConnection()
        else:
            self.connection = connection

    def sexpr(self):
        return self._sexpr

    def compile(self):
        return self._compile_sexpr(self.sexpr())

    def run(self):
        return self.connection.run(self)

    def map(self, function):
        assert self.value_type is not None, "Attempted to call map on non iterable StraboObject"
        return self.from_sexpr("map", self.from_sexpr("lambda", ("arg",),
                                                      function(arg_from_type(self.value_type))), self)

    def __repr__(self):
        return "<Strabo Query: " + self.compile() + " >"

    def _compile_sexpr(self, sexpr):
        tail = [self._format_arg(arg) for arg in sexpr[1:]]
        return '(' + ' '.join([sexpr[0]] + tail) + ')'

    def _format_arg(self, arg):
        if isinstance(arg, basestring):
            return '"' + arg.replace('\\', '\\\\').replace('"', '\\"') + '"'
        elif isinstance(arg, tuple):
            return self._compile_sexpr(arg)
        else:
            return unicode(arg)

    def from_sexpr(self, *args):
        sexpr = tuple(arg.sexpr() if isinstance(arg, StraboObject) else arg
                      for arg in args)
        new_object = StraboObject(connection = self.connection)
        new_object._sexpr = sexpr
        new_object.value_type = self.value_type
        return new_object
